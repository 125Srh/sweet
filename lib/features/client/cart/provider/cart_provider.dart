import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/cart_service.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  int _totalItems = 0;
  bool _loading = false;
  bool _processing = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get items => _items;
  int get totalItems => _totalItems;
  bool get loading => _loading;
  bool get processing => _processing;
  String? get errorMessage => _errorMessage;

  double get subtotal => _items.fold<double>(0, (sum, item) {
    final cantidad = item['cantidad'] as int;
    final precio = (item['precio_unitario'] as num).toDouble();
    return sum + (cantidad * precio);
  });

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> cargar() async {
    if (_userId == null) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await CartService.getItems(_userId!);
      _totalItems = _items.fold<int>(0, (s, i) => s + (i['cantidad'] as int));
    } catch (e) {
      _errorMessage = 'Error al cargar el carrito: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> agregar({
    required String productoId,
    required double precioUnitario,
    int cantidad = 1,
  }) async {
    if (_userId == null) {
      _errorMessage = 'Debes iniciar sesión.';
      notifyListeners();
      return false;
    }
    if (_processing) return false;
    _processing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await CartService.agregarProducto(
        usuarioId: _userId!,
        productoId: productoId,
        precioUnitario: precioUnitario,
        cantidad: cantidad,
      );
      await cargar();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<bool> actualizar(String itemId, int nuevaCantidad) async {
    if (_processing) return false;

    final index = _items.indexWhere((i) => i['id'].toString() == itemId);
    if (index == -1) {
      _errorMessage = 'Producto no encontrado.';
      notifyListeners();
      return false;
    }

    if (nuevaCantidad < 1) {
      _errorMessage = 'La cantidad mínima es 1.';
      notifyListeners();
      return false;
    }

    final producto = _items[index]['producto'] as Map<String, dynamic>? ?? {};
    final stock = (producto['stock'] as int?) ?? 0;

    if (nuevaCantidad > stock) {
      _errorMessage = 'Solo hay $stock unidades disponibles.';
      notifyListeners();
      return false;
    }

    // Cambio local inmediato
    _items[index]['cantidad'] = nuevaCantidad;
    _totalItems = _items.fold<int>(0, (s, i) => s + (i['cantidad'] as int));
    notifyListeners();

    // Sync en segundo plano
    _processing = true;
    try {
      await CartService.actualizarCantidad(itemId, nuevaCantidad);
    } catch (e) {
      _errorMessage = 'Error al sincronizar. Intenta de nuevo.';
      notifyListeners();
    } finally {
      _processing = false;
      notifyListeners();
    }

    return true;
  }

  Future<bool> incrementar(String itemId) async {
    final item = _items.firstWhere(
      (i) => i['id'].toString() == itemId,
      orElse: () => {},
    );
    if (item.isEmpty) {
      _errorMessage = 'Producto no encontrado.';
      notifyListeners();
      return false;
    }
    final cantidadActual = item['cantidad'] as int;
    return await actualizar(itemId, cantidadActual + 1);
  }

  Future<bool> decrementar(String itemId) async {
    final item = _items.firstWhere(
      (i) => i['id'].toString() == itemId,
      orElse: () => {},
    );
    if (item.isEmpty) {
      _errorMessage = 'Producto no encontrado.';
      notifyListeners();
      return false;
    }
    final cantidadActual = item['cantidad'] as int;
    if (cantidadActual <= 1) {
      _errorMessage =
          'La cantidad mínima es 1. Usa eliminar para quitar el producto.';
      notifyListeners();
      return false;
    }
    return await actualizar(itemId, cantidadActual - 1);
  }

  Future<bool> eliminar(String itemId) async {
    if (_processing) return false;

    _processing = true;
    _errorMessage = null;

    final index = _items.indexWhere((i) => i['id'].toString() == itemId);
    if (index == -1) {
      _errorMessage = 'El producto ya no está en tu carrito.';
      _processing = false;
      notifyListeners();
      return false;
    }

    final itemBackup = Map<String, dynamic>.from(_items[index]);

    _items.removeAt(index);
    _totalItems = _items.fold<int>(0, (s, i) => s + (i['cantidad'] as int));
    notifyListeners();

    try {
      await CartService.eliminarItem(itemId);
      return true;
    } catch (e) {
      _items.insert(index, itemBackup);
      _totalItems = _items.fold<int>(0, (s, i) => s + (i['cantidad'] as int));
      _errorMessage = 'Error al eliminar. Intenta de nuevo.';
      notifyListeners();
      return false;
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  Future<bool> vaciar() async {
    if (_userId == null || _processing) return false;

    _processing = true;
    _errorMessage = null;

    final itemsBackup = List<Map<String, dynamic>>.from(_items);
    final totalBackup = _totalItems;

    _items = [];
    _totalItems = 0;
    notifyListeners();

    try {
      await CartService.vaciarCarrito(_userId!);
      return true;
    } catch (e) {
      _items = itemsBackup;
      _totalItems = totalBackup;
      _errorMessage = 'Error al vaciar el carrito.';
      notifyListeners();
      return false;
    } finally {
      _processing = false;
      notifyListeners();
    }
  }
}
