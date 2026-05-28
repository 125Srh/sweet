// lib/features/client/home/service/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  static final _db = Supabase.instance.client;

  /// Trae el detalle del pedido con nombre e imagen de cada producto
  Future<List<Map<String, dynamic>>> getDetallePedido(String pedidoId) async {
    try {
      final res = await _db
          .from('pedido_detalle')
          .select('''
            id,
            cantidad,
            precio_unitario,
            subtotal,
            producto:producto_id (
              id,
              nombre,
              imagen_url
            )
          ''')
          .eq('pedido_id', pedidoId);

      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      print('❌ Error cargando detalle del pedido: $e');
      return [];
    }
  }
}