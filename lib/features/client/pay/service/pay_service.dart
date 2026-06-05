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
      final productosDisponibles = <Map<String, dynamic>>[];
      final productosAgotados = <Map<String, dynamic>>[];

      for (final producto in productos) {
        final productoId = producto['producto_id'].toString();
        final cantidad = producto['cantidad'] as int;
        final nombre = producto['nombre'].toString();

        final resultado = await _db.rpc(
          'descontar_stock',
          params: {'p_producto_id': productoId, 'p_cantidad': cantidad},
        );

        print('🔍 RPC resultado: $resultado | tipo: ${resultado.runtimeType}');

        final bool exito = resultado == true;

        print('🔍 exito: $exito | producto: $nombre');

        if (exito) {
          productosDisponibles.add(producto);
        } else {
          productosAgotados.add({...producto, 'nombre': nombre});
        }
      }

      // Ningún producto disponible → no crear pedido
      if (productosDisponibles.isEmpty) {
        return PedidoResult(
          pedidoId: null,
          exitoTotal: false,
          productosAgotadosNombres: productosAgotados
              .map((p) => p['nombre'].toString())
              .toList(),
          productosCompradosNombres: [],
          productosCompradosIds: [],
          totalDisponibles: 0.0,
        );
      }

      // Calcular totales solo de productos disponibles
      final double subtotalDisponibles = productosDisponibles.fold(0.0, (
        sum,
        p,
      ) {
        return sum +
            ((p['cantidad'] as int) * (p['precio_unitario'] as num).toDouble());
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
      final pedidoDetalles = productosDisponibles.map((p) {
        final cantidad = p['cantidad'] as int;
        final precio = (p['precio_unitario'] as num).toDouble();
        return {
          'pedido_id': pedidoId,
          'producto_id': p['producto_id'],
          'cantidad': cantidad,
          'precio_unitario': precio,
          'subtotal': cantidad * precio,
        };
      }).toList();

      await _db.from('pedido_detalle').insert(pedidoDetalles);

      // Notificaciones de stock post-descuento
      for (final producto in productosDisponibles) {
        final productoId = producto['producto_id'].toString();
        final nombre = producto['nombre'].toString();

        final stockRes = await _db
            .from('producto')
            .select('stock')
            .eq('id', productoId)
            .single();

        final stockNuevo = (stockRes['stock'] as int?) ?? 0;

        await _notificarStockSiNecesario(
          productoId: productoId,
          nombre: nombre,
          stockNuevo: stockNuevo,
        );
      }

      return PedidoResult(
        pedidoId: pedidoId,
        exitoTotal: productosAgotados.isEmpty,
        productosAgotadosNombres: productosAgotados
            .map((p) => p['nombre'].toString())
            .toList(),
        productosCompradosNombres: productosDisponibles
            .map((p) => p['nombre'].toString())
            .toList(),
        productosCompradosIds: productosDisponibles
            .map((p) => p['producto_id'].toString())
            .toList(),
        totalDisponibles: totalDisponibles,
      );
    } catch (e) {
      print('❌ Error en crearPedido: $e');
      throw Exception('Error al crear el pedido: $e');
    }
  }

  static Future<void> _notificarStockSiNecesario({
    required String productoId,
    required String nombre,
    required int stockNuevo,
  }) async {
    try {
      if (stockNuevo <= 0) {
        await _db.from('notificaciones').insert({
          'tipo': 'agotado',
          'titulo': '🚨 Producto agotado',
          'mensaje': '$nombre se ha agotado. ¡Repón cuanto antes!',
          'producto_id': productoId,
          'leida': false,
        });
      } else if (stockNuevo <= 3) {
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
