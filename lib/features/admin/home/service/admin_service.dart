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
  // 👥 CLIENTES — HU-19
  // ══════════════════════════════════════════════════════════

  /// Trae todos los usuarios con rol 'cliente' desde Supabase
  Future<List<Map<String, dynamic>>> getClientes() async {
    try {
      final res = await supabase
          .from('usuario')
          .select('id, nombre, apellido, email, telefono, activo, created_at')
          .eq('rol', 'cliente')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando clientes: $e");
      rethrow;
    }
  }

  /// Stream en tiempo real de clientes registrados
  Stream<List<Map<String, dynamic>>> streamClientes() {
    return supabase
        .from('usuario')
        .stream(primaryKey: ['id'])
        .eq('rol', 'cliente')
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ══════════════════════════════════════════════════════════
  // 🔔 NOTIFICACIONES
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

  /// Crea una notificación de venta nueva — HU-22
  Future<void> crearNotificacionVenta({
    required String nombreCliente,
    required double totalPedido,
    required String pedidoId,
  }) async {
    try {
      await supabase.from('notificaciones').insert({
        'tipo': 'nueva_venta',
        'titulo': 'Nueva venta realizada',
        'mensaje':
            '$nombreCliente realizó un pedido por Bs. ${totalPedido.toStringAsFixed(2)}',
        'pedido_id': pedidoId,
        'leida': false,
      });
      print("✅ Notificación de venta creada");
    } catch (e) {
      print("❌ Error creando notificación de venta: $e");
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
  // 📋 HISTORIAL DE STOCK
  // ══════════════════════════════════════════════════════════

  Future<void> registrarHistorial({
    required String productoId,
    required int cantidadAnterior,
    required int cantidadNueva,
    required String usuarioId,
  }) async {
    try {
      await supabase.from('historial_stock').insert({
        'producto_id': productoId,
        'cantidad_anterior': cantidadAnterior,
        'cantidad_nueva': cantidadNueva,
        'usuario_id': usuarioId,
      });
    } catch (e) {
      print("❌ Error registrando historial: $e");
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🔥 STREAMS TIEMPO REAL
  // ══════════════════════════════════════════════════════════

  Stream<List<Map<String, dynamic>>> streamNotificaciones() {
    return supabase
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .order('creada_en', ascending: false)
        .limit(30)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> streamProductos() {
    return supabase
        .from('producto')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Stream de notificaciones de ventas en tiempo real — HU-22
  Stream<List<Map<String, dynamic>>> streamNotificacionesVentas() {
    return supabase
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .eq('tipo', 'nueva_venta')
        .order('creada_en', ascending: false)
        .limit(50)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<List<Map<String, dynamic>>> getPedidos() async {
    try {
      final res = await supabase
          .from('pedido')
          .select('''
          id,
          total,
          estado,
          fecha_pedido,
          usuario:usuario_id (nombre, apellido)
        ''')
          .order('fecha_pedido', ascending: false);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error cargando pedidos: $e");
      return [];
    }
  }

  Future<void> actualizarEstadoPedido(String id, String estado) async {
    try {
      await supabase
          .from('pedido')
          .update({
            'estado': estado,
            'fecha_actualizacion': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      print("✅ Estado actualizado");
    } catch (e) {
      print("❌ Error actualizando pedido: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getDetallePedido(String pedidoId) async {
    try {
      final res = await supabase
          .from('pedido_detalle')
          .select('''
          cantidad,
          subtotal,
          producto:producto_id (nombre)
        ''')
          .eq('pedido_id', pedidoId);

      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ Error detalle pedido: $e");
      return [];
    }
  }
}
