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
}
