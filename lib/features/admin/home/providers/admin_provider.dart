// lib/features/admin/home/providers/admin_provider.dart
import 'package:flutter/material.dart';
import '../service/admin_service.dart';

class AdminsProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  bool isLoading = false;

  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> marcas = [];
  List<Map<String, dynamic>> productos = [];

  String _searchQuery = '';

  // ══════════════════════════════════════════════════════════
  // 🔍 BÚSQUEDA
  // ══════════════════════════════════════════════════════════

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredProductos {
    if (_searchQuery.isEmpty) return productos;
    return productos.where((p) {
      final nombre = (p['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // ══════════════════════════════════════════════════════════
  // 📊 ALERTAS DE STOCK (computed localmente)
  // ══════════════════════════════════════════════════════════

  List<Map<String, dynamic>> get productosStockBajo {
    return productos.where((p) {
      final stock = (p['stock'] as int?) ?? 0;
      return stock > 0 && stock <= 3;
    }).toList();
  }

  List<Map<String, dynamic>> get productosAgotados {
    return productos.where((p) {
      final stock = (p['stock'] as int?) ?? 0;
      return stock <= 0;
    }).toList();
  }

  int get totalAlertas => productosStockBajo.length + productosAgotados.length;

  // ══════════════════════════════════════════════════════════
  // 🔔 CREAR NOTIFICACIÓN DE STOCK
  // ══════════════════════════════════════════════════════════

  Future<void> _notificarStock(
    String nombre,
    int stock,
    String productoId,
  ) async {
    if (stock <= 0) {
      await _service.crearNotificacion(
        tipo: 'agotado',
        titulo: '🚨 Producto agotado',
        mensaje: '$nombre se ha agotado. ¡Repón cuanto antes!',
        productoId: productoId,
      );
    } else if (stock <= 3) {
      await _service.crearNotificacion(
        tipo: 'stock_bajo',
        titulo: '⚠️ Stock bajo',
        mensaje: 'Solo quedan $stock unidades de $nombre',
        productoId: productoId,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // 📦 PRODUCTOS — CRUD
  // ══════════════════════════════════════════════════════════

  Future<void> cargarProductos() async {
    try {
      isLoading = true;
      notifyListeners();
      productos = await _service.getProductos();
    } catch (e) {
      print("❌ Error cargando productos: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required String imagen,
    required String categoriaId,
    required String marcaId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.crearProducto({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'stock': stock,
        'imagen_url': imagen,
        'categoria_id': categoriaId,
        'marca_id': marcaId,
      });

      // Recargar para obtener el ID real del producto recién creado
      await cargarProductos();

      // Usar el último producto cargado para la notificación
      final productoId = productos.isNotEmpty
          ? productos.first['id']
                .toString() // ordenado por fecha desc
          : '';

      if (productoId.isNotEmpty) {
        await _notificarStock(nombre, stock, productoId);
      }

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required String imagen,
    required String categoriaId,
    required String marcaId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.actualizarProducto(id, {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'stock': stock,
        'imagen_url': imagen,
        'categoria_id': categoriaId,
        'marca_id': marcaId,
      });

      // Notificar si el stock es bajo o está agotado
      await _notificarStock(nombre, stock, id);

      await cargarProductos();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> eliminarProducto(dynamic id) async {
    try {
      isLoading = true;
      notifyListeners();
      await _service.eliminarProducto(id);
      await cargarProductos();
    } catch (e) {
      print("❌ Error eliminando producto: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🏷️ CATEGORÍAS Y MARCAS
  // ══════════════════════════════════════════════════════════

  Future<void> cargarCategoriasYMarcas() async {
    try {
      isLoading = true;
      notifyListeners();
      categorias = await _service.getCategorias();
      marcas = await _service.getMarcas();
    } catch (e) {
      print("❌ Error cargando categorías/marcas: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
