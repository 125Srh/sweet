// lib/features/client/pay/service/pay_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PayService {
  static final _db = Supabase.instance.client;

  static Future<PedidoResult> crearPedido({
    required String usuarioId,
    required double subtotal,
    required double envio,
    required double total,
    required String direccion,
    required String referencia,
    required String celular,
    required String metodoPago,
    required List<Map<String, dynamic>> productos,
  }) async {
    try {
      // 1. Consultar el stock actual en base de datos de todos los productos
      final productIds = productos.map((p) => p['producto_id'].toString()).toList();
      final productsInDb = await _db
          .from('producto')
          .select('id, nombre, stock')
          .inFilter('id', productIds);

      final stockMap = {
        for (var p in productsInDb)
          p['id'].toString(): {
            'stock': (p['stock'] as int?) ?? 0,
            'nombre': p['nombre'].toString(),
          }
      };

      // 2. Clasificar productos en disponibles y agotados
      final productosDisponibles = <Map<String, dynamic>>[];
      final productosAgotados = <Map<String, dynamic>>[];

      for (final p in productos) {
        final pId = p['producto_id'].toString();
        final cant = p['cantidad'] as int;
        final dbProduct = stockMap[pId];
        final dbStock = dbProduct != null ? (dbProduct['stock'] as int) : 0;
        final nombre = dbProduct != null ? dbProduct['nombre'] : (p['nombre'] ?? 'Producto');

        if (dbStock >= cant) {
          productosDisponibles.add(p);
        } else {
          productosAgotados.add({
            ...p,
            'nombre': nombre,
          });
        }
      }

      // 3. Caso: Ningún producto disponible
      if (productosAgotados.isNotEmpty && productosDisponibles.isEmpty) {
        return PedidoResult(
          pedidoId: null,
          exitoTotal: false,
          productosAgotadosNombres: productosAgotados.map((p) => p['nombre'].toString()).toList(),
          productosCompradosNombres: [],
          productosCompradosIds: [],
          totalDisponibles: 0.0,
        );
      }

      // 4. Caso: Hay productos disponibles (pueden ser todos o algunos)
      final double subtotalDisponibles = productosDisponibles.fold<double>(0, (sum, p) {
        final cant = p['cantidad'] as int;
        final precio = (p['precio_unitario'] as num).toDouble();
        return sum + (cant * precio);
      });
      final double totalDisponibles = subtotalDisponibles + envio;

      // Crear el pedido
      final pedidoResult = await _db
          .from('pedido')
          .insert({
            'usuario_id': usuarioId,
            'estado': 'pendiente',
            'subtotal': subtotalDisponibles,
            'total': totalDisponibles,
            'costo_envio': envio,
            'metodo_pago': metodoPago,
            'direccion_entrega': direccion,
            'notas': referencia.isEmpty ? null : referencia,
            'telefono_receptor': celular,
          })
          .select('id')
          .single();

      final pedidoId = pedidoResult['id'].toString();

      // Crear detalles del pedido
      final pedidoDetalles = productosDisponibles.map((producto) {
        final cantidad = producto['cantidad'] as int;
        final precioUnitario = (producto['precio_unitario'] as num).toDouble();
        return {
          'pedido_id': pedidoId,
          'producto_id': producto['producto_id'],
          'cantidad': cantidad,
          'precio_unitario': precioUnitario,
          'subtotal': cantidad * precioUnitario,
        };
      }).toList();

      await _db.from('pedido_detalle').insert(pedidoDetalles);

      // Descontar stock y notificar
      for (final producto in productosDisponibles) {
        final productoId = producto['producto_id'] as String;
        final cantidadVendida = producto['cantidad'] as int;
        final nombreProducto = producto['nombre'].toString();

        final dbProduct = stockMap[productoId];
        final stockActual = dbProduct != null ? (dbProduct['stock'] as int) : 0;
        final stockNuevo = (stockActual - cantidadVendida).clamp(0, 99999);

        await _db.rpc(
          'descontar_stock',
          params: {'p_producto_id': productoId, 'p_cantidad': cantidadVendida},
        );

        print(
          '✅ Stock descontado: $nombreProducto | $stockActual → $stockNuevo',
        );

        await _notificarStockSiNecesario(
          productoId: productoId,
          nombre: nombreProducto,
          stockAnterior: stockActual,
          stockNuevo: stockNuevo,
        );
      }

      return PedidoResult(
        pedidoId: pedidoId,
        exitoTotal: productosAgotados.isEmpty,
        productosAgotadosNombres: productosAgotados.map((p) => p['nombre'].toString()).toList(),
        productosCompradosNombres: productosDisponibles.map((p) => p['nombre'].toString()).toList(),
        productosCompradosIds: productosDisponibles.map((p) => p['producto_id'].toString()).toList(),
        totalDisponibles: totalDisponibles,
      );
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
    }
  }

  static Future<void> _notificarStockSiNecesario({
    required String productoId,
    required String nombre,
    required int stockAnterior,
    required int stockNuevo,
  }) async {
    try {
      if (stockNuevo <= 0 && stockAnterior > 0) {
        await _db.from('notificaciones').insert({
          'tipo': 'agotado',
          'titulo': '🚨 Producto agotado',
          'mensaje': '$nombre se ha agotado. ¡Repón cuanto antes!',
          'producto_id': productoId,
          'leida': false,
        });
        return;
      }

      if (stockNuevo <= 3 && stockNuevo > 0 && stockAnterior > 3) {
        await _db.from('notificaciones').insert({
          'tipo': 'stock_bajo',
          'titulo': '⚠️ Stock bajo',
          'mensaje': 'Solo quedan $stockNuevo unidades de $nombre',
          'producto_id': productoId,
          'leida': false,
        });
        return;
      }

      if (stockNuevo <= 3 && stockNuevo > 0 && stockAnterior <= 3) {
        await _db.from('notificaciones').insert({
          'tipo': 'stock_bajo',
          'titulo': '⚠️ Stock bajo',
          'mensaje': 'Solo quedan $stockNuevo unidades de $nombre',
          'producto_id': productoId,
          'leida': false,
        });
      }
    } catch (e) {
      print('⚠️ Error creando notificación de stock: $e');
    }
  }

  // ← FIX: elimina solo los items pagados, no todo el carrito
  static Future<void> eliminarItemsPagados(
    String usuarioId,
    List<String> productoIds,
  ) async {
    try {
      final carritoRes = await _db
          .from('carrito')
          .select('id')
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (carritoRes == null) return;

      final carritoId = carritoRes['id'].toString();

      final items = await _db
          .from('carrito_item')
          .select('id, producto_id')
          .eq('carrito_id', carritoId);

      final idsAEliminar = (items as List)
          .where((item) => productoIds.contains(item['producto_id'].toString()))
          .map((item) => item['id'].toString())
          .toList();

      if (idsAEliminar.isEmpty) return;

      await _db.from('carrito_item').delete().inFilter('id', idsAEliminar);
    } catch (e) {
      throw Exception('Error al eliminar items pagados: $e');
    }
  }

  static Future<void> vaciarCarrito(String usuarioId) async {
    try {
      final carritoRes = await _db
          .from('carrito')
          .select('id')
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (carritoRes != null) {
        await _db
            .from('carrito_item')
            .delete()
            .eq('carrito_id', carritoRes['id'].toString());
      }
    } catch (e) {
      throw Exception('Error al vaciar el carrito: $e');
    }
  }
}

class PedidoResult {
  final String? pedidoId;
  final bool exitoTotal;
  final List<String> productosAgotadosNombres;
  final List<String> productosCompradosNombres;
  final List<String> productosCompradosIds;
  final double totalDisponibles;

  PedidoResult({
    this.pedidoId,
    required this.exitoTotal,
    required this.productosAgotadosNombres,
    required this.productosCompradosNombres,
    required this.productosCompradosIds,
    required this.totalDisponibles,
  });
}
