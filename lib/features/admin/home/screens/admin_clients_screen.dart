// lib/features/admin/home/screens/admin_clients_screen.dart
import 'package:flutter/material.dart';
import '../service/admin_service.dart';
import '../widgets/admin_drawer.dart'; // ← importar el drawer

class AdminClientsScreen extends StatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  State<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends State<AdminClientsScreen> {
  final AdminService _service = AdminService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _filtrados = [];
  bool _loading = true;
  String _filtroEstado = 'todos';

  static const _pink = Color(0xFFFF69B4);

  @override
  void initState() {
    super.initState();
    _service.streamClientes().listen((lista) {
      if (!mounted) return;
      setState(() {
        _clientes = lista;
        _aplicarFiltro(_searchCtrl.text);
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _aplicarFiltro(String texto) {
    final q = texto.toLowerCase();
    setState(() {
      _filtrados = _clientes.where((c) {
        final nombre = '${c['nombre'] ?? ''} ${c['apellido'] ?? ''}'
            .toLowerCase();
        final correo = (c['email'] ?? '').toString().toLowerCase();
        return nombre.contains(q) || correo.contains(q);
      }).toList();
    });
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return '—';
    final dt = DateTime.tryParse(fecha);
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Widget _buildFiltros() {
    final filtros = [
      {'valor': 'todos', 'label': 'Todos', 'color': Colors.grey},
      {'valor': 'activo', 'label': 'Activos', 'color': Colors.green},
      {'valor': 'inactivo', 'label': 'Inactivos', 'color': Colors.orange},
      {'valor': 'sin_compras', 'label': 'Sin compras', 'color': Colors.red},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filtros.map((f) {
            final seleccionado = _filtroEstado == f['valor'];
            final color = f['color'] as Color;
            return GestureDetector(
              onTap: () => setState(() => _filtroEstado = f['valor'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: seleccionado ? color : color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: seleccionado ? color : color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  f['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: seleccionado ? Colors.white : color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      // ← Drawer agregado aquí
      drawer: const AdminDrawer(selectedIndex: 1),
      appBar: AppBar(
        backgroundColor: _pink,
        elevation: 0,
        // ← Hamburguesa en lugar de flecha
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Clientes registrados',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_clientes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_clientes.length} clientes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────
          Container(
            color: _pink,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _aplicarFiltro,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchCtrl.clear();
                          _aplicarFiltro('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Contenido ──────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _pink))
                : Column(
                    children: [
                      _buildFiltros(),
                      const Divider(height: 1),
                      Expanded(
                        child: _filtrados.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filtrados.length,
                                itemBuilder: (_, i) {
                                  final cliente = _filtrados[i];

                                  if (_filtroEstado != 'todos') {
                                    return FutureBuilder<String>(
                                      future: _service.getEstadoCliente(
                                        cliente['id'].toString(),
                                        cliente['created_at'] ?? '',
                                      ),
                                      builder: (context, snap) {
                                        if (!snap.hasData)
                                          return const SizedBox();
                                        if (snap.data != _filtroEstado)
                                          return const SizedBox();
                                        return _ClienteTile(
                                          cliente: cliente,
                                          fecha: _formatearFecha(
                                            cliente['created_at'],
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  return _ClienteTile(
                                    cliente: cliente,
                                    fecha: _formatearFecha(
                                      cliente['created_at'],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchCtrl.text.isNotEmpty
                ? 'No se encontraron clientes'
                : 'No hay clientes registrados',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchCtrl.text.isNotEmpty
                ? 'Intenta con otro nombre o correo'
                : 'Los clientes aparecerán aquí al registrarse',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de cliente ─────────────────────────────────────────
class _ClienteTile extends StatefulWidget {
  final Map<String, dynamic> cliente;
  final String fecha;

  const _ClienteTile({required this.cliente, required this.fecha});

  @override
  State<_ClienteTile> createState() => _ClienteTileState();
}

class _ClienteTileState extends State<_ClienteTile> {
  final AdminService _service = AdminService();
  String _estado = 'cargando';

  @override
  void initState() {
    super.initState();
    _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    final estado = await _service.getEstadoCliente(
      widget.cliente['id'].toString(),
      widget.cliente['created_at'] ?? '',
    );
    if (mounted) setState(() => _estado = estado);
  }

  Color get _badgeColor {
    switch (_estado) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.orange;
      case 'sin_compras':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _badgeLabel {
    switch (_estado) {
      case 'activo':
        return 'Activo';
      case 'inactivo':
        return 'Inactivo';
      case 'sin_compras':
        return 'Sin compras';
      default:
        return '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre =
        '${widget.cliente['nombre'] ?? ''} ${widget.cliente['apellido'] ?? ''}'
            .trim();
    final correo = widget.cliente['email']?.toString() ?? '—';
    final telefono = widget.cliente['telefono']?.toString() ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF69B4).withOpacity(0.4),
                ),
              ),
              child: Center(
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD81B60),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre.isNotEmpty ? nombre : 'Sin nombre',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _badgeColor, width: 1),
                        ),
                        child: Text(
                          _badgeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          correo,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        telefono,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Desde ${widget.fecha}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
