// lib/features/admin/home/providers/admin_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/admin_service.dart';

class AdminsProvider extends ChangeNotifier {
  final AdminService _service = AdminService();
  final _db = Supabase.instance.client;

  bool isLoading = false;

  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> marcas = [];
  List<Map<String, dynamic>> productos = [];

  String _searchQuery = '';

  RealtimeChannel? _productosChannel;

  // ══════════════════════════════════════════════════════════
  // 🔴 REALTIME
  // ══════════════════════════════════════════════════════════

  void suscribirseAProductos() {
    if (_productosChannel != null) return;

    _productosChannel = _db
        .channel('admin-productos-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'producto',
          callback: (payload) {
            final productoActualizado = payload.newRecord;
            final id = productoActualizado['id']?.toString();
            if (id == null) return;

            final index = productos.indexWhere((p) => p['id'].toString() == id);
            if (index != -1) {
              productos[index] = Map<String, dynamic>.from(productoActualizado);
              notifyListeners();
              print(
                '🔄 Stock actualizado en tiempo real: ${productoActualizado['nombre']} → stock: ${productoActualizado['stock']}',
              );
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'producto',
          callback: (payload) {
            cargarProductos();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'producto',
          callback: (payload) {
            final id = payload.oldRecord['id']?.toString();
            if (id != null) {
              productos.removeWhere((p) => p['id'].toString() == id);
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  Future<void> cancelarSuscripcion() async {
    if (_productosChannel != null) {
      await _db.removeChannel(_productosChannel!);
      _productosChannel = null;
    }
  }

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
  // 📊 ALERTAS DE STOCK
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
  // 🔔 NOTIFICACIONES DE STOCK
  // ══════════════════════════════════════════════════════════

  Future<void> _notificarStock(
    String nombre,
    int stockAnterior,
    int stockNuevo,
    String productoId,
  ) async {
    // ✅ NUEVO: reposición de stock (el admin subió el stock)
    if (stockNuevo > stockAnterior) {
      final repuesto = stockNuevo - stockAnterior;
      await _service.crearNotificacion(
        tipo: 'reposicion',
        titulo: '📦 Stock repuesto',
        mensaje:
            'Se agregaron $repuesto unidades a $nombre. Stock actual: $stockNuevo',
        productoId: productoId,
      );
      return;
    }

    // Stock bajo o agotado (el admin bajó el stock manualmente)
    if (stockNuevo <= 0) {
      await _service.crearNotificacion(
        tipo: 'agotado',
        titulo: '🚨 Producto agotado',
        mensaje: '$nombre se ha agotado. ¡Repón cuanto antes!',
        productoId: productoId,
      );
    } else if (stockNuevo <= 3) {
      await _service.crearNotificacion(
        tipo: 'stock_bajo',
        titulo: '⚠️ Stock bajo',
        mensaje: 'Solo quedan $stockNuevo unidades de $nombre',
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
    required double precioAdquisicion,
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
        'precio_adquisicion': precioAdquisicion,
        'stock': stock,
        'imagen_url': imagen,
        'categoria_id': categoriaId,
        'marca_id': marcaId,
      });

      await cargarProductos();

      final productoId = productos.isNotEmpty
          ? productos.first['id'].toString()
          : '';

      if (productoId.isNotEmpty) {
        // Al crear, no hay stock anterior — notificar solo si ya nace con stock bajo
        await _notificarStock(nombre, 0, stock, productoId);
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
    required double precioAdquisicion,
    required int stock,
    required String imagen,
    required String categoriaId,
    required String marcaId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // ✅ Obtener stock anterior antes de actualizar
      final productoActual = productos.firstWhere(
        (p) => p['id'].toString() == id,
        orElse: () => {},
      );
      final stockAnterior = (productoActual['stock'] as int?) ?? 0;

      await _service.actualizarProducto(id, {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'precio_adquisicion': precioAdquisicion,
        'stock': stock,
        'imagen_url': imagen,
        'categoria_id': categoriaId,
        'marca_id': marcaId,
      });

      // ✅ Notificar según el cambio de stock (reposición, bajo o agotado)
      await _notificarStock(nombre, stockAnterior, stock, id);

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
