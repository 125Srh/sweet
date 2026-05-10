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
      // 1. Insertar en la tabla 'pedido'
      final pedidoResult = await _db.from('pedido').insert({
        'usuario_id': usuarioId,
        'estado': 'pendiente',
        'subtotal': subtotal,
        'total': total,
        'costo_envio': envio,
        'metodo_pago': metodoPago,
        'direccion_entrega': direccion,
        'notas': referencia.isEmpty ? null : referencia,
        'telefono_receptor': celular,
      }).select('id').single();

      final pedidoId = pedidoResult['id'].toString();

      // 2. Insertar los productos en la tabla 'pedido_detalle'
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

      return pedidoId;
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
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