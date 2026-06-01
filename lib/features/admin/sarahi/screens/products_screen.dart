import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'reporte_ventas_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final SupabaseService _service = SupabaseService();
  List<Map<String, dynamic>> _productos = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int _selectedIndex = 1;
  
  // AÑADIR ESTA VARIABLE
  Widget _currentScreen = const SizedBox();

  final Color _pinkColor = const Color(0xFFFF69B4);

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _currentScreen = _buildMainContent(); // AÑADIR ESTA LÍNEA
  }

  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);
    final productos = await _service.getProductos();
    setState(() {
      _productos = productos;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _productos;
    return _productos.where((product) =>
        product['nombre'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        product['codigo'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // AÑADIR ESTE MÉTODO PARA CAMBIAR DE PANTALLA
  void _cambiarPantalla(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 4) {
        _currentScreen = const ReporteVentasScreen();
      } else {
        _currentScreen = _buildMainContent();
      }
    });
  }

  // ========== MENÚ LATERAL ESTÁTICO (para LAPTOP) ==========
  Widget _buildStaticMenu() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: _pinkColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 45, color: _pinkColor),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sweet',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white54, thickness: 1),
          _buildStaticMenuItem(Icons.dashboard_outlined, 'Inicio', 0),
          _buildStaticMenuItem(Icons.inventory_2_outlined, 'Productos', 1),
          _buildStaticMenuItem(Icons.people_outline, 'Clientes', 2),
          _buildStaticMenuItem(Icons.shopping_cart_outlined, 'Ventas', 3),
          _buildStaticMenuItem(Icons.bar_chart_outlined, 'Reportes', 4),
          const Spacer(),
          const Divider(color: Colors.white54, thickness: 1),
          _buildStaticMenuItem(Icons.settings_outlined, 'Configuración', -1),
          _buildStaticMenuItem(Icons.logout, 'Cerrar Sesión', -2, color: Colors.red[300]),
        ],
      ),
    );
  }

  Widget _buildStaticMenuItem(IconData icon, String title, int index, {Color? color}) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.white, size: 22),
        title: Text(
          title,
          style: TextStyle(color: color ?? Colors.white, fontSize: 14),
        ),
        dense: true,
        onTap: () {
          _cambiarPantalla(index); // MODIFICADO
        },
      ),
    );
  }

  // ========== DRAWER (menú hamburguesa para CELULAR) ==========
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(color: _pinkColor),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 50, color: _pinkColor),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sweet',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          _buildDrawerMenuItem(Icons.dashboard_outlined, 'Inicio', 0),
          _buildDrawerMenuItem(Icons.inventory_2_outlined, 'Productos', 1),
          _buildDrawerMenuItem(Icons.people_outline, 'Clientes', 2),
          _buildDrawerMenuItem(Icons.shopping_cart_outlined, 'Ventas', 3),
          _buildDrawerMenuItem(Icons.bar_chart_outlined, 'Reportes', 4),
          const Spacer(),
          const Divider(),
          _buildDrawerMenuItem(Icons.settings_outlined, 'Configuración', -1),
          _buildDrawerMenuItem(Icons.logout, 'Cerrar Sesión', -2, color: Colors.red[300]),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem(IconData icon, String title, int index, {Color? color}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? _pinkColor : (color ?? Colors.grey[700])),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? _pinkColor : (color ?? Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? _pinkColor.withOpacity(0.1) : null,
      onTap: () {
        _cambiarPantalla(index); // MODIFICADO
        Navigator.pop(context);
      },
    );
  }

  // ========== NAVBAR SUPERIOR (para LAPTOP) ==========
  Widget _buildDesktopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedIndex == 4 ? 'Reportes de Ventas' : 'Productos',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.print, color: Colors.grey[700], size: 22),
                onPressed: () => _showMessage('Imprimir'),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.grey[700], size: 22),
                onPressed: () => _showMessage('Ajustes'),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: Colors.grey[700], size: 22),
                    onPressed: () => _showMessage('Notificaciones'),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _cerrarSesionConfirmacion,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _pinkColor,
                        child: const Icon(Icons.person, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Admin',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== CONTENIDO PRINCIPAL (COMPARTIDO) ==========
  Widget _buildMainContent() {
    return Column(
      children: [
        // Panel Gestión
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestión de productos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Los productos son los artículos que se venden en la empresa.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showMessage('Registrar Producto - Próximamente'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Registrar Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Buscador
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
          ),
        ),
        
        // Tabla productos
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
                  ? const Center(child: Text('No hay productos registrados'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DataTable(
                        columnSpacing: 12,
                        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                        columns: const [
                          DataColumn(label: Text('IMG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('NOMBRE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('UNIDAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('STOCK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('PRECIO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('COSTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('ACC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                        rows: _filteredProducts.map((producto) {
                          return DataRow(cells: [
                            DataCell(
                              Container(
                                width: 35,
                                height: 35,
                                color: Colors.grey[200],
                                child: Icon(Icons.image, size: 20, color: Colors.grey[600]),
                              ),
                            ),
                            DataCell(Text(producto['codigo'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(producto['nombre'] ?? 'Sin nombre', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(producto['unidad_medida'] ?? 'UNIDAD', style: const TextStyle(fontSize: 12))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (producto['stock'] ?? 0) < 5 ? Colors.red[100] : Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (producto['stock'] ?? 0).toString(),
                                  style: TextStyle(
                                    color: (producto['stock'] ?? 0) < 5 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text((producto['precio'] ?? 0).toStringAsFixed(0), style: const TextStyle(fontSize: 12))),
                            DataCell(Text((producto['costo'] ?? 0).toStringAsFixed(0), style: const TextStyle(fontSize: 12))),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red, size: 18),
                                onPressed: () => _confirmarEliminar(producto),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
        ),
        
        // Barra inferior
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_filteredProducts.length} productos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Sweet v1.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detectar si es pantalla pequeña (celular) o grande (laptop/tablet)
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // ========== MODO CELULAR: AppBar con menú hamburguesa ==========
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedIndex == 4 ? 'Reportes de Ventas' : 'Sweet',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _pinkColor,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.print, color: Colors.white, size: 22),
              onPressed: () => _showMessage('Imprimir'),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white, size: 22),
              onPressed: () => _showMessage('Ajustes'),
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.white, size: 22),
                  onPressed: () => _showMessage('Notificaciones'),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _cerrarSesionConfirmacion,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: _pinkColor, size: 18),
                ),
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: _selectedIndex == 4 ? const ReporteVentasScreen() : _buildMainContent(),
      );
    } else {
      // ========== MODO LAPTOP/TABLET: Menú lateral estático ==========
      return Scaffold(
        body: Row(
          children: [
            _buildStaticMenu(),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopNavBar(),
                  Expanded(child: _selectedIndex == 4 ? const ReporteVentasScreen() : _buildMainContent()),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _cerrarSesionConfirmacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Estás segura que deseas salir de Sweet?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (!context.mounted) return;
        context.go('/login');
      } catch (e) {
        debugPrint("❌ [LOGOUT ERROR] Falló al hacer signOut: $e");
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${producto['nombre']}" permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _service.supabase
            .from('producto')
            .update({'activo': false})
            .eq('id', producto['id']);
        _cargarProductos();
        _showMessage('Producto eliminado');
      } catch (e) {
        _showMessage('Error: $e');
      }
    }
  }
}