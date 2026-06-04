import 'package:supabase_flutter/supabase_flutter.dart';

class CartServiceException implements Exception {
  final String message;
  CartServiceException(this.message);
  @override
  String toString() => message;
}

class CartService {
  static final _db = Supabase.instance.client;

  static Future<String> _getOrCreateCarrito(String usuarioId) async {
    final res = await _db
        .from('carrito')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (res != null) return res['id'].toString();

    final nuevo = await _db
        .from('carrito')
        .insert({'usuario_id': usuarioId})
        .select('id')
        .single();
    return nuevo['id'].toString();
  }

  static Future<int> getStockProducto(String productoId) async {
    try {
      final res = await _db
          .from('producto')
          .select('stock')
          .eq('id', productoId)
          .maybeSingle();

      if (res == null) {
        throw CartServiceException('El producto ya no está disponible.');
      }
      return (res['stock'] as int?) ?? 0;
    } catch (e) {
      if (e is CartServiceException) rethrow;
      throw CartServiceException('Error al consultar el stock del producto.');
    }
  }

  static Future<bool> productoExiste(String productoId) async {
    try {
      final res = await _db
          .from('producto')
          .select('id')
          .eq('id', productoId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  static Future<void> agregarProducto({
    required String usuarioId,
    required String productoId,
    required double precioUnitario,
    int cantidad = 1,
  }) async {
    if (cantidad < 1) {
      throw CartServiceException('La cantidad mínima es 1.');
    }

    final stock = await getStockProducto(productoId);
    if (stock <= 0) {
      throw CartServiceException('Producto agotado.');
    }

    final carritoId = await _getOrCreateCarrito(usuarioId);

    final itemExistente = await _db
        .from('carrito_item')
        .select('id, cantidad')
        .eq('carrito_id', carritoId)
        .eq('producto_id', productoId)
        .maybeSingle();

    if (itemExistente != null) {
      final nuevaCantidad = (itemExistente['cantidad'] as int) + cantidad;
      if (nuevaCantidad > stock) {
        throw CartServiceException(
          'Stock insuficiente. Solo hay $stock disponibles '
          'y ya tienes ${itemExistente['cantidad']} en tu carrito.',
        );
      }
      await _db
          .from('carrito_item')
          .update({'cantidad': nuevaCantidad})
          .eq('id', itemExistente['id'].toString());
    } else {
      if (cantidad > stock) {
        throw CartServiceException('Solo hay $stock unidades disponibles.');
      }
      await _db.from('carrito_item').insert({
        'carrito_id': carritoId,
        'producto_id': productoId,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getItems(String usuarioId) async {
    final carritoRes = await _db
        .from('carrito')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (carritoRes == null) return [];

    final carritoId = carritoRes['id'].toString();

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

  static Future<void> actualizarCantidad(
    String itemId,
    int nuevaCantidad,
  ) async {
    if (nuevaCantidad <= 0) {
      throw CartServiceException(
        'La cantidad mínima es 1. Si deseas quitar el producto, usa eliminar.',
      );
    }

    final itemActual = await _db
        .from('carrito_item')
        .select('producto_id, cantidad')
        .eq('id', itemId)
        .maybeSingle();

    if (itemActual == null) {
      throw CartServiceException('El producto ya no está en tu carrito.');
    }

    final productoId = itemActual['producto_id'] as String;
    final stock = await getStockProducto(productoId);

    if (nuevaCantidad > stock) {
      throw CartServiceException(
        'Stock insuficiente. Solo hay $stock unidades disponibles.',
      );
    }

    await _db
        .from('carrito_item')
        .update({'cantidad': nuevaCantidad})
        .eq('id', itemId);
  }

  static Future<void> eliminarItem(String itemId) async {
    final existe = await _db
        .from('carrito_item')
        .select('id')
        .eq('id', itemId)
        .maybeSingle();

    if (existe == null) {
      throw CartServiceException('El producto ya no está en tu carrito.');
    }

    await _db.from('carrito_item').delete().eq('id', itemId);
  }

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
      0,
      (sum, i) => sum + (i['cantidad'] as int),
    );
  }
}
