// lib/features/client/pay/service/pay_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PayService {
  static final _db = Supabase.instance.client;

  static Future<String> crearPedido({
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
      // ── 1. Insertar pedido ──────────────────────────────────────────
      final pedidoResult = await _db
          .from('pedido')
          .insert({
            'usuario_id': usuarioId,
            'estado': 'pendiente',
            'subtotal': subtotal,
            'total': total,
            'costo_envio': envio,
            'metodo_pago': metodoPago,
            'direccion_entrega': direccion,
            'notas': referencia.isEmpty ? null : referencia,
            'telefono_receptor': celular,
          })
          .select('id')
          .single();

      final pedidoId = pedidoResult['id'].toString();

      // ── 2. Insertar detalle del pedido ──────────────────────────────
      final pedidoDetalles = productos.map((producto) {
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

      // ── 3. Descontar stock y notificar si es necesario ──────────────
      for (final producto in productos) {
        final productoId = producto['producto_id'].toString();
        final cantidadVendida = producto['cantidad'] as int;
        final nombreProducto = producto['nombre'].toString();

        // Obtener stock actual
        final productoActual = await _db
            .from('producto')
            .select('stock')
            .eq('id', productoId)
            .single();

        final stockActual = (productoActual['stock'] as int?) ?? 0;
        final stockNuevo = (stockActual - cantidadVendida).clamp(0, 99999);

        // Descontar stock en la BD
        await _db
            .from('producto')
            .update({'stock': stockNuevo})
            .eq('id', productoId);

        // Crear notificación si el stock quedó bajo o agotado
        await _notificarStockSiNecesario(
          productoId: productoId,
          nombre: nombreProducto,
          stockAnterior: stockActual,
          stockNuevo: stockNuevo,
        );
      }

      return pedidoId;
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
    }
  }

  // ── Lógica de notificación ────────────────────────────────────────────
  static Future<void> _notificarStockSiNecesario({
    required String productoId,
    required String nombre,
    required int stockAnterior,
    required int stockNuevo,
  }) async {
    try {
      // Solo notificar si el stock cruzó un umbral (evita duplicados)
      // Caso 1: se agotó ahora (antes tenía stock, ahora = 0)
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

      // Caso 2: bajó a stock bajo (1-3 unidades) y antes estaba bien
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

      // Caso 3: ya estaba en stock bajo y sigue bajando (actualiza mensaje)
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
      // No interrumpir el flujo de compra si falla la notificación
      print('⚠️ Error creando notificación de stock: $e');
    }
  }

  // ── Vaciar carrito ────────────────────────────────────────────────────
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
