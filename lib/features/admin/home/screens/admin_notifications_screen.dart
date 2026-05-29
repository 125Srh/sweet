// lib/features/admin/home/screens/admin_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/admin_service.dart';
import '../widgets/admin_drawer.dart'; // ← agregado

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final AdminService _service = AdminService();

  List<Map<String, dynamic>> _notificaciones = [];
  bool _loading = true;
  int _noLeidas = 0;

  static const _pink = Color(0xFFFF1362);

  @override
  void initState() {
    super.initState();
    _service.streamNotificacionesVentas().listen((lista) {
      if (!mounted) return;
      setState(() {
        _notificaciones = lista;
        _noLeidas = lista.where((n) => n['leida'] == false).length;
        _loading = false;
      });
    });
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return '—';
    final dt = DateTime.tryParse(fecha);
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _abrirDetalle(Map<String, dynamic> notificacion) async {
    await _service.marcarComoLeida(notificacion['id'].toString());
    if (!mounted) return;

    List<Map<String, dynamic>> detalles = [];
    String? pedidoInfo;

    try {
      final mensaje = notificacion['mensaje']?.toString() ?? '';
      final fechaNotif = notificacion['creada_en']?.toString();

      final regexMonto = RegExp(r'por Bs\.\s*([\d]+(?:[.,]\d+)?)');
      final match = regexMonto.firstMatch(mensaje);
      final montoStr = match?.group(1)?.replaceAll(',', '.');
      final monto = montoStr != null ? double.tryParse(montoStr) : null;

      final regexNombre = RegExp(r'^(.+?)\s+realizó');
      final matchNombre = regexNombre.firstMatch(mensaje);
      final nombreEnMensaje = matchNombre?.group(1);

      final pedidos = await Supabase.instance.client
          .from('pedido')
          .select(
            'id, total, estado, fecha_pedido, usuario:usuario_id(nombre, apellido)',
          )
          .order('fecha_pedido', ascending: false)
          .limit(30);

      Map<String, dynamic>? pedidoEncontrado;
      final dtNotif = fechaNotif != null ? DateTime.tryParse(fechaNotif) : null;

      for (final pedido in pedidos) {
        final dtPedido = DateTime.tryParse(
          pedido['fecha_pedido']?.toString() ?? '',
        );
        final totalPedido = double.tryParse(pedido['total']?.toString() ?? '');
        final coincideMonto =
            monto != null &&
            totalPedido != null &&
            (monto - totalPedido).abs() < 0.5;
        final coincideTiempo =
            dtNotif != null &&
            dtPedido != null &&
            dtNotif.difference(dtPedido).abs().inMinutes <= 10;
        if (coincideMonto && coincideTiempo) {
          pedidoEncontrado = pedido;
          break;
        }
      }

      if (pedidoEncontrado == null && dtNotif != null) {
        for (final pedido in pedidos) {
          final dtPedido = DateTime.tryParse(
            pedido['fecha_pedido']?.toString() ?? '',
          );
          if (dtPedido != null &&
              dtNotif.difference(dtPedido).abs().inMinutes <= 5) {
            pedidoEncontrado = pedido;
            break;
          }
        }
      }

      if (pedidoEncontrado == null && pedidos.isNotEmpty)
        pedidoEncontrado = pedidos.first;

      if (pedidoEncontrado != null) {
        final pid = pedidoEncontrado['id'].toString();
        detalles = await _service.getDetallePedido(pid);
        final usuario = pedidoEncontrado['usuario'];
        final nombreReal = usuario != null
            ? '${usuario['nombre']} ${usuario['apellido']}'.trim()
            : (nombreEnMensaje ?? 'Cliente');
        pedidoInfo = 'Pedido de $nombreReal — Bs. ${pedidoEncontrado['total']}';
      }
    } catch (e) {
      debugPrint('⚠️ Error buscando pedido: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFCE4EC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🛍️ Detalle de la venta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _pink.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: _pink, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pedidoInfo ?? notificacion['mensaje'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              detalles.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No se encontraron productos\npara este pedido',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: detalles.length,
                        itemBuilder: (_, i) {
                          final item = detalles[i];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag,
                                  color: Colors.pink,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item['producto']?['nombre'] ?? '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('x${item['cantidad']}'),
                                    Text(
                                      'Bs. ${item['subtotal']}',
                                      style: const TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      drawer: const AdminDrawer(selectedIndex: 3), // ← drawer agregado
      appBar: AppBar(
        backgroundColor: _pink,
        elevation: 0,
        // ← hamburguesa en lugar de flecha
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Notificaciones de ventas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            if (_noLeidas > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_noLeidas',
                  style: const TextStyle(
                    color: _pink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_noLeidas > 0)
            TextButton(
              onPressed: _service.marcarTodasComoLeidas,
              child: const Text(
                'Marcar todas',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _pink))
          : _notificaciones.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notificaciones.length,
              itemBuilder: (_, i) {
                final n = _notificaciones[i];
                return _VentaTile(
                  notificacion: n,
                  tiempo: _formatearFecha(n['creada_en']),
                  onTap: () => _abrirDetalle(n),
                  onEliminar: () =>
                      _service.eliminarNotificacion(n['id'].toString()),
                );
              },
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none, size: 70, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text(
          'Sin notificaciones de ventas',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aquí aparecerán los pedidos\nque realicen los clientes',
          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
class _VentaTile extends StatelessWidget {
  final Map<String, dynamic> notificacion;
  final String tiempo;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _VentaTile({
    required this.notificacion,
    required this.tiempo,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final leida = notificacion['leida'] as bool? ?? false;
    final titulo = notificacion['titulo']?.toString() ?? 'Nueva venta';
    final mensaje = notificacion['mensaje']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: leida ? Colors.white : const Color(0xFFFF69B4).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: leida
              ? Colors.grey.shade100
              : const Color(0xFFFF69B4).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: leida
                        ? Colors.grey.withOpacity(0.1)
                        : const Color(0xFFFF1362).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: leida ? Colors.grey : const Color(0xFFFF1362),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontWeight: leida
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 14,
                          color: leida ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mensaje,
                        style: TextStyle(
                          fontSize: 13,
                          color: leida ? Colors.grey : const Color(0xFFD81B60),
                          fontWeight: leida
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 12,
                            color: leida
                                ? Colors.grey[400]
                                : const Color(0xFFFF69B4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Toca para ver el pedido',
                            style: TextStyle(
                              fontSize: 11,
                              color: leida
                                  ? Colors.grey[400]
                                  : const Color(0xFFFF69B4),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            tiempo,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          if (!leida) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF1362),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Nueva',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEliminar,
                  icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
