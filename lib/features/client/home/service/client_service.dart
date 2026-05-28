import 'package:supabase_flutter/supabase_flutter.dart';

class ClientService {
  final supabase = Supabase.instance.client;

  // 🔥 Obtener productos destacados
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    final response = await supabase
        .from('producto')
        .select()
        .eq('activo', true)
        .eq('destacado', true);

    return List<Map<String, dynamic>>.from(response);
  }

  // 🔥 Obtener productos por categoría
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String categoriaId,
  ) async {
    final response = await supabase
        .from('producto')
        .select()
        .eq('categoria_id', categoriaId)
        .eq('activo', true);

    return List<Map<String, dynamic>>.from(response);
  }

  // 🔥 Obtener categorías
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await supabase
        .from('categoria')
        .select()
        .eq('activo', true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final response = await supabase
        .from('producto')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMisPedidos() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    final res = await supabase
        .from('pedido')
        .select()
        .eq('usuario_id', user.id)
        .order('fecha_pedido', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> marcarComoRecibido(String pedidoId) async {
    await supabase
        .from('pedido')
        .update({
          'estado': 'recibido',
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        })
        .eq('id', pedidoId);
  }
}
