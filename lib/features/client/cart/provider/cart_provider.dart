import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/cart_service.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  int _totalItems = 0;
  bool _loading = false;

  List<Map<String, dynamic>> get items    => _items;
  int                        get totalItems => _totalItems;
  bool                       get loading  => _loading;

  double get subtotal => _items.fold<double>(0, (sum, item) {
    final cantidad = item['cantidad'] as int;
    final precio   = (item['precio_unitario'] as num).toDouble();
    return sum + (cantidad * precio);
  });

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  // ── Cargar items ─────────────────────────────────────────────
  Future<void> cargar() async {
    if (_userId == null) return;
    _loading = true;
    notifyListeners();
    try {
      _items      = await CartService.getItems(_userId!);
      _totalItems = _items.fold<int>(0, (s, i) => s + (i['cantidad'] as int));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Agregar producto ─────────────────────────────────────────
  Future<void> agregar({
    required String productoId,
    required double precioUnitario,
    int cantidad = 1,
  }) async {
    if (_userId == null) return;
    await CartService.agregarProducto(
      usuarioId: _userId!,
      productoId: productoId,
      precioUnitario: precioUnitario,
      cantidad: cantidad,
    );
    await cargar();
  }

  // ── Actualizar cantidad ──────────────────────────────────────
  Future<void> actualizar(String itemId, int nuevaCantidad) async {
    await CartService.actualizarCantidad(itemId, nuevaCantidad);
    await cargar();
  }

  // ── Eliminar item ────────────────────────────────────────────
  Future<void> eliminar(String itemId) async {
    await CartService.eliminarItem(itemId);
    await cargar();
  }

  // ── Vaciar carrito ───────────────────────────────────────────
  Future<void> vaciar() async {
    if (_userId == null) return;
    await CartService.vaciarCarrito(_userId!);
    _items      = [];
    _totalItems = 0;
    notifyListeners();
  }
}