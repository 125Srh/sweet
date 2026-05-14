// lib/features/admin/home/screens/admin_notifications_screen.dart
import 'package:flutter/material.dart';
import '../service/admin_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen> {
  final AdminService _service = AdminService();

  List<Map<String, dynamic>> _notificaciones = [];
  bool _loading = true;
  int _noLeidas = 0;

  static const _pink = Color(0xFFFF1362);

  @override
  void initState() {
    super.initState();
    // Escucha notificaciones de ventas en tiempo real — T2, T3
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
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Future<void> _marcarTodas() async {
    await _service.marcarTodasComoLeidas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: _pink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          const Text(
            'Notificaciones de ventas',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17),
          ),
          if (_noLeidas > 0) ...[
            const SizedBox(width: 8),
            // Badge no leídas — T7
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_noLeidas',
                style: const TextStyle(
                    color: _pink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ]),
        actions: [
          if (_noLeidas > 0)
            TextButton(
              onPressed: _marcarTodas,
              child: const Text(
                'Marcar todas',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _pink))
          : _notificaciones.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notificaciones.length,
                  itemBuilder: (_, i) {
                    final n = _notificaciones[i];
                    return _NotificacionVentaTile(
                      notificacion: n,
                      tiempo: _formatearFecha(n['creada_en']),
                      onTap: () async {
                        // Marcar como leída al tocar — T6
                        await _service.marcarComoLeida(
                            n['id'].toString());
                        // Aquí puedes navegar al detalle del pedido
                        // cuando tengas la pantalla de pedidos lista:
                        // context.push('/admin/pedido/${n['pedido_id']}');
                      },
                      onEliminar: () async {
                        await _service.eliminarNotificacion(
                            n['id'].toString());
                      },
                    );
                  },
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none,
              size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Sin notificaciones de ventas',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí aparecerán los nuevos pedidos\nque realicen los clientes',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de notificación de venta ─────────────────────────
class _NotificacionVentaTile extends StatelessWidget {
  final Map<String, dynamic> notificacion;
  final String tiempo;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _NotificacionVentaTile({
    required this.notificacion,
    required this.tiempo,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final leida   = notificacion['leida'] as bool? ?? false;
    final titulo  = notificacion['titulo']?.toString() ?? 'Nueva venta';
    final mensaje = notificacion['mensaje']?.toString() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: leida
              ? Colors.white
              : const Color(0xFFFF69B4).withOpacity(0.06),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono de venta
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

              // Texto — T5
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontWeight:
                            leida ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                        color: leida ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mensaje,
                      style: TextStyle(
                        fontSize: 13,
                        color: leida
                            ? Colors.grey
                            : const Color(0xFFD81B60),
                        fontWeight: leida
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.access_time,
                          size: 12,
                          color: leida
                              ? Colors.grey[400]
                              : const Color(0xFFFF69B4)),
                      const SizedBox(width: 4),
                      Text(
                        tiempo,
                        style: TextStyle(
                          fontSize: 11,
                          color: leida
                              ? Colors.grey[400]
                              : const Color(0xFFFF69B4),
                        ),
                      ),
                      if (!leida) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF1362),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Nueva',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),

              // Botón eliminar
              GestureDetector(
                onTap: onEliminar,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child:
                      Icon(Icons.close, size: 18, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}