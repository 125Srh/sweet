import 'package:flutter/material.dart';
import '../service/admin_service.dart';

class AdminsProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  bool isLoading = false;

  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> marcas = [];
  List<Map<String, dynamic>> productos = [];

  String _searchQuery = '';

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

      await cargarProductos();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR CATEGORÍAS Y MARCAS
  Future<void> cargarCategoriasYMarcas() async {
    try {
      isLoading = true;
      notifyListeners();

      categorias = await _service.getCategorias();
      marcas = await _service.getMarcas();
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 PRODUCTOS
  Future<void> cargarProductos() async {
    try {
      isLoading = true;
      notifyListeners();

      productos = await _service.getProductos();
    } catch (e) {
      print(e);
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
      print(e);
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

      await cargarProductos();

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
