import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final supabase = Supabase.instance.client;

  // 🔥 PRODUCTOS
  Future<List<Map<String, dynamic>>> getProductos() async {
    try {
      final res = await supabase.from('producto').select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando productos: $e");
      rethrow;
    }
  }

  Future<void> crearProducto(Map<String, dynamic> data) async {
    try {
      final res = await supabase.from('producto').insert(data);

      print("✅ Producto insertado correctamente");
      print("DATA: $data");
      print("RESPUESTA: $res");
    } catch (e) {
      print("❌ ERROR AL CREAR PRODUCTO");
      print("DATA ENVIADA: $data");
      print("ERROR: $e");

      rethrow; // 🔥 importante para que el provider lo capture
    }
  }

  Future<void> eliminarProducto(dynamic id) async {
    try {
      await supabase.from('producto').delete().eq('id', id);
      print("🗑️ Producto eliminado: $id");
    } catch (e) {
      print("❌ Error eliminando producto: $e");
    }
  }

  // 🔥 CATEGORÍAS
  Future<List<Map<String, dynamic>>> getCategorias() async {
    try {
      final res = await supabase.from('categoria').select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando categorías: $e");
      rethrow;
    }
  }

  // 🔥 MARCAS
  Future<List<Map<String, dynamic>>> getMarcas() async {
    try {
      final res = await supabase.from('marca').select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando marcas: $e");
      rethrow;
    }
  }

  Future<void> actualizarProducto(String id, Map<String, dynamic> data) async {
    try {
      await supabase.from('producto').update(data).eq('id', id);

      print("✏️ Producto actualizado: $id");
    } catch (e) {
      print("❌ Error actualizando producto: $e");
      rethrow;
    }
  }
}
