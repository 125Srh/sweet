// lib/features/client/home/screen/order_detail_screen.dart
import 'package:flutter/material.dart';
import '../service/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pedido;

  const OrderDetailScreen({super.key, required this.pedido});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _service = OrderService();
  List<Map<String, dynamic>> _detalles = [];
  bool _loading = true;

  final Color rosaPrincipal = const Color(0xFFFF69B4);
  final Color rosaSuave = const Color(0xFFFFF0F5);

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final id = widget.pedido['id']?.toString() ?? '';
    try {
      final res = await _service.getDetallePedido(id);
      if (mounted) setState(() { _detalles = res; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Helpers de estado ────────────────────────────────────
  String _estadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':       return 'Pendiente';
      case 'en_preparacion':  return 'En preparación';
      case 'listo':           return 'Listo';
      case 'enviado':         return 'Enviado';
      case 'recibido':        return 'Recibido';
      default:                return estado;
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente':       return Colors.grey.shade500;
      case 'en_preparacion':  return Colors.amber.shade700;
      case 'listo':           return Colors.lightBlue.shade400;
      case 'enviado':         return Colors.purple.shade300;
      case 'recibido':        return Colors.pink.shade300;
      default:                return Colors.black;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':       return Icons.favorite_border_rounded;
      case 'en_preparacion':  return Icons.auto_awesome_rounded;
      case 'listo':           return Icons.card_giftcard_rounded;
      case 'enviado':         return Icons.local_shipping_rounded;
      case 'recibido':        return Icons.celebration_rounded;
      default:                return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado        = widget.pedido['estado']?.toString() ?? 'pendiente';
    final total         = widget.pedido['total'];
    final subtotal      = widget.pedido['subtotal'];
    final costoEnvio    = widget.pedido['costo_envio'];
    final direccion     = widget.pedido['direccion_entrega']?.toString() ?? '—';
    final metodoPago    = widget.pedido['metodo_pago']?.toString() ?? '—';
    final fechaPedido   = widget.pedido['fecha_pedido']?.toString();
    final notas         = widget.pedido['notas']?.toString();

    // Formatear fecha
    String fechaFormato = '—';
    if (fechaPedido != null) {
      final dt = DateTime.tryParse(fechaPedido);
      if (dt != null) {
        fechaFormato =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Scaffold(
      backgroundColor: rosaSuave,
      appBar: AppBar(
        title: const Text(
          'Detalle del pedido',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: rosaPrincipal,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: rosaPrincipal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Estado del pedido ──────────────────────
                  _seccion(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estado del pedido',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _estadoColor(estado).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_estadoIcon(estado),
                                  color: _estadoColor(estado), size: 14),
                              const SizedBox(width: 5),
                              Text(
                                _estadoLabel(estado),
                                style: TextStyle(
                                  color: _estadoColor(estado),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Info del pedido ────────────────────────
                  _seccion(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoFila(Icons.calendar_today_outlined,
                            'Fecha', fechaFormato),
                        const SizedBox(height: 10),
                        _infoFila(Icons.location_on_outlined,
                            'Dirección de entrega', direccion),
                        const SizedBox(height: 10),
                        _infoFila(Icons.payment_outlined,
                            'Método de pago',
                            metodoPago == 'tarjeta_simulada'
                                ? 'Tarjeta de crédito/débito'
                                : 'Pago contra entrega'),
                        if (notas != null &&
                            notas.isNotEmpty &&
                            !notas.startsWith('asignado:')) ...[
                          const SizedBox(height: 10),
                          _infoFila(
                              Icons.notes_outlined, 'Notas', notas),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Productos del pedido ───────────────────
                  const Text(
                    'Productos',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFD81B60)),
                  ),
                  const SizedBox(height: 8),

                  _detalles.isEmpty
                      ? _seccion(
                          child: Center(
                            child: Column(children: [
                              Icon(Icons.inbox_outlined,
                                  size: 40,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text('No hay productos registrados',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13)),
                            ]),
                          ),
                        )
                      : Column(
                          children: _detalles.asMap().entries.map((e) {
                            final i = e.key;
                            final item = e.value;
                            final nombreProducto =
                                item['producto']?['nombre']?.toString() ??
                                    'Producto';
                            final imagenUrl =
                                item['producto']?['imagen_url']?.toString();
                            final cantidad =
                                (item['cantidad'] as int?) ?? 1;
                            final precioUnit =
                                (item['precio_unitario'] as num?)
                                    ?.toDouble() ??
                                    0.0;
                            final subtotalItem =
                                (item['subtotal'] as num?)?.toDouble() ??
                                    (cantidad * precioUnit);

                            return Container(
                              margin: EdgeInsets.only(
                                  bottom:
                                      i < _detalles.length - 1 ? 10 : 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: rosaPrincipal.withOpacity(0.12),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        rosaPrincipal.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(children: [
                                  // Imagen
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      color: rosaPrincipal.withOpacity(0.1),
                                      child: imagenUrl != null &&
                                              imagenUrl.isNotEmpty
                                          ? Image.network(imagenUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(Icons.spa,
                                                      color: rosaPrincipal,
                                                      size: 28))
                                          : Icon(Icons.spa,
                                              color: rosaPrincipal,
                                              size: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Info producto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(nombreProducto,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Bs. ${precioUnit.toStringAsFixed(2)} c/u',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Cantidad y subtotal
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: rosaPrincipal.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text('x$cantidad',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: rosaPrincipal)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Bs. ${subtotalItem.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: rosaPrincipal),
                                      ),
                                    ],
                                  ),
                                ]),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 16),

                  // ── Resumen de totales ─────────────────────
                  _seccion(
                    child: Column(children: [
                      _filaTotal('Subtotal',
                          'Bs. ${(subtotal as num?)?.toStringAsFixed(2) ?? '—'}'),
                      const SizedBox(height: 8),
                      _filaTotal('Costo de envío',
                          'Bs. ${(costoEnvio as num?)?.toStringAsFixed(2) ?? '—'}'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Color(0xFFFFE4E9)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD81B60))),
                          Text(
                            'Bs. ${(total as num?)?.toStringAsFixed(2) ?? '—'}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: rosaPrincipal),
                          ),
                        ],
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ── Widgets auxiliares ──────────────────────────────────
  Widget _seccion({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rosaPrincipal.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: rosaPrincipal.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _infoFila(IconData icon, String label, String valor) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: rosaPrincipal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      );

  Widget _filaTotal(String label, String valor) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(valor,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      );
}