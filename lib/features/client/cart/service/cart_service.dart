import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  static final _db = Supabase.instance.client;

  // ── Obtener o crear carrito del usuario ──────────────────────
  static Future<String> _getOrCreateCarrito(String usuarioId) async {
    // Buscar carrito existente
    final res = await _db
        .from('carrito')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (res != null) return res['id'].toString();

    // Crear nuevo carrito
    final nuevo = await _db
        .from('carrito')
        .insert({'usuario_id': usuarioId})
        .select('id')
        .single();
    return nuevo['id'].toString();
  }

  // ── Agregar producto al carrito ──────────────────────────────
  static Future<void> agregarProducto({
    required String usuarioId,
    required String productoId,
    required double precioUnitario,
    int cantidad = 1,
  }) async {
    final carritoId = await _getOrCreateCarrito(usuarioId);

    // Verificar si ya existe el item
    final itemExistente = await _db
        .from('carrito_item')
        .select('id, cantidad')
        .eq('carrito_id', carritoId)
        .eq('producto_id', productoId)
        .maybeSingle();

    if (itemExistente != null) {
      // Incrementar cantidad
      final nuevaCantidad = (itemExistente['cantidad'] as int) + cantidad;
      await _db
          .from('carrito_item')
          .update({'cantidad': nuevaCantidad})
          .eq('id', itemExistente['id'].toString());
    } else {
      // Insertar nuevo item
      await _db.from('carrito_item').insert({
        'carrito_id': carritoId,
        'producto_id': productoId,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
      });
    }
  }

  // ── Obtener items del carrito ────────────────────────────────
  // Sin join a marca para evitar errores si marca_id es null
  static Future<List<Map<String, dynamic>>> getItems(String usuarioId) async {
    final carritoRes = await _db
        .from('carrito')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (carritoRes == null) return [];

    final carritoId = carritoRes['id'].toString();

    // Traer items con producto — sin join a marca (puede ser null)
    final items = await _db
        .from('carrito_item')
        .select('''
          id,
          cantidad,
          precio_unitario,
          producto:producto_id (
            id,
            nombre,
            imagen_url,
            stock,
            precio
          )
        ''')
        .eq('carrito_id', carritoId);

    return List<Map<String, dynamic>>.from(items as List);
  }

  // ── Actualizar cantidad de un item ───────────────────────────
  static Future<void> actualizarCantidad(String itemId, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await eliminarItem(itemId);
      return;
    }
    await _db
        .from('carrito_item')
        .update({'cantidad': nuevaCantidad})
        .eq('id', itemId);
  }

  // ── Eliminar item del carrito ────────────────────────────────
  static Future<void> eliminarItem(String itemId) async {
    await _db.from('carrito_item').delete().eq('id', itemId);
  }

  // ── Vaciar carrito completo ──────────────────────────────────
  static Future<void> vaciarCarrito(String usuarioId) async {
    final carritoRes = await _db
        .from('carrito')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    if (carritoRes == null) return;
    await _db
        .from('carrito_item')
        .delete()
        .eq('carrito_id', carritoRes['id'].toString());
  }

  // ── Contar items totales en el carrito ───────────────────────
  static Future<int> contarItems(String usuarioId) async {
    final carritoRes = await _db
        .from('carrito')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    if (carritoRes == null) return 0;

    final items = await _db
        .from('carrito_item')
        .select('cantidad')
        .eq('carrito_id', carritoRes['id'].toString());

    return (items as List).fold<int>(
        0, (sum, i) => sum + (i['cantidad'] as int));
  }
}