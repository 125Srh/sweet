// lib/features/admin/home/service/admin_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final supabase = Supabase.instance.client;

  // ══════════════════════════════════════════════════════════
  // 🛒 PRODUCTOS
  // ══════════════════════════════════════════════════════════

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
      await supabase.from('producto').insert(data);
      print("✅ Producto insertado correctamente");
    } catch (e) {
      print("❌ ERROR AL CREAR PRODUCTO: $e");
      rethrow;
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

  Future<void> actualizarProducto(String id, Map<String, dynamic> data) async {
    try {
      await supabase.from('producto').update(data).eq('id', id);
      print("✏️ Producto actualizado: $id");
    } catch (e) {
      print("❌ Error actualizando producto: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🏷️ CATEGORÍAS
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getCategorias() async {
    try {
      final res = await supabase.from('categoria').select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando categorías: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🏢 MARCAS
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getMarcas() async {
    try {
      final res = await supabase.from('marca').select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando marcas: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🔔 NOTIFICACIONES — Consultas normales
  // ══════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> getNotificaciones() async {
    try {
      final res = await supabase
          .from('notificaciones')
          .select()
          .order('creada_en', ascending: false)
          .limit(30);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando notificaciones: $e");
      return [];
    }
  }

  Future<int> getNotificacionesNoLeidas() async {
    try {
      final res = await supabase
          .from('notificaciones')
          .select()
          .eq('leida', false);
      return res.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> crearNotificacion({
    required String tipo,
    required String titulo,
    required String mensaje,
    String? productoId,
  }) async {
    try {
      await supabase.from('notificaciones').insert({
        'tipo': tipo,
        'titulo': titulo,
        'mensaje': mensaje,
        'producto_id': productoId,
      });
    } catch (e) {
      print("❌ Error creando notificación: $e");
    }
  }

  Future<void> marcarComoLeida(String id) async {
    try {
      await supabase
          .from('notificaciones')
          .update({'leida': true})
          .eq('id', id);
    } catch (e) {
      print("❌ Error marcando notificación como leída: $e");
    }
  }

  Future<void> marcarTodasComoLeidas() async {
    try {
      await supabase
          .from('notificaciones')
          .update({'leida': true})
          .eq('leida', false);
    } catch (e) {
      print("❌ Error marcando todas como leídas: $e");
    }
  }

  Future<void> eliminarNotificacion(String id) async {
    try {
      await supabase.from('notificaciones').delete().eq('id', id);
      print("🗑️ Notificación eliminada: $id");
    } catch (e) {
      print("❌ Error eliminando notificación: $e");
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🔥 STREAM EN TIEMPO REAL — WebSocket con Supabase Realtime
  //
  // IMPORTANTE: Para que funcione, ve a tu dashboard de Supabase →
  // Table Editor → tabla "notificaciones" → activa "Enable Realtime"
  // ══════════════════════════════════════════════════════════

  Stream<List<Map<String, dynamic>>> streamNotificaciones() {
    return supabase
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .order('creada_en', ascending: false)
        .limit(30)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
