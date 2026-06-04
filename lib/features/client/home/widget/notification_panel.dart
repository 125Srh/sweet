import 'package:flutter/material.dart';

class NotificationPanel extends StatelessWidget {
  final LayerLink layerLink;
  final List<Map<String, dynamic>> notificaciones;
  final int noLeidas;
  final VoidCallback onClose;
  final void Function(String id) onMarcarLeida;
  final void Function(String id) onEliminar;
  final VoidCallback onMarcarTodas;
  final void Function(Map<String, dynamic> notif) onVerProducto; // 👈 nuevo

  const NotificationPanel({
    super.key,
    required this.layerLink,
    required this.notificaciones,
    required this.noLeidas,
    required this.onClose,
    required this.onMarcarLeida,
    required this.onEliminar,
    required this.onMarcarTodas,
    required this.onVerProducto, // 👈 nuevo
  });

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'nuevo_producto':
        return Icons.new_releases;
      case 'promocion':
        return Icons.local_offer;
      case 'pedido':
        return Icons.shopping_bag;
      case 'recordatorio':
        return Icons.access_time;
      case 'cumpleanos':
        return Icons.cake;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'nuevo_producto':
        return const Color(0xFF27AE60);
      case 'promocion':
        return const Color(0xFFFF69B4);
      case 'pedido':
        return const Color(0xFF2196F3);
      case 'recordatorio':
        return const Color(0xFFFF9800);
      case 'cumpleanos':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _formatearTiempo(String fecha) {
    final diff = DateTime.now().difference(DateTime.parse(fecha));
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return 'Hace ${diff.inDays ~/ 7} sem';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          offset: const Offset(-270, 56),
          showWhenUnlinked: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 340,
              constraints: const BoxConstraints(maxHeight: 520),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── HEADER ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Color(0xFFFF69B4),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Notificaciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFD81B60),
                          ),
                        ),
                        if (noLeidas > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF69B4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$noLeidas',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (noLeidas > 0)
                          TextButton(
                            onPressed: onMarcarTodas,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Marcar todas',
                              style: TextStyle(
                                color: Color(0xFFFF69B4),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                  ),

                  // ── CONTENIDO ──
                  if (notificaciones.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF69B4).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off,
                              color: Color(0xFFFF69B4),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '¡Todo en orden!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFD81B60),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No hay notificaciones nuevas',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: notificaciones.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (ctx, i) {
                          final n = notificaciones[i];
                          final tipo = n['tipo'] ?? 'info';
                          final leida = n['leida'] ?? false;
                          final color = _colorTipo(tipo);
                          return _NotificationCard(
                            icono: _iconoTipo(tipo),
                            color: color,
                            leida: leida,
                            tipo: tipo,
                            titulo: n['titulo'] ?? '',
                            mensaje: n['mensaje'] ?? '',
                            tiempo: _formatearTiempo(n['creada_en']),
                            imagenUrl: n['producto']?['imagen_url'],
                            precio: n['producto']?['precio'],
                            onTap: () => onMarcarLeida(n['id']),
                            onEliminar: () => onEliminar(n['id']),
                            onVerProducto: n['producto_id'] != null
                                ? () => onVerProducto(n)
                                : null,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── TARJETA ───────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final IconData icono;
  final Color color;
  final bool leida;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String tiempo;
  final String? imagenUrl;
  final dynamic precio;
  final VoidCallback onTap;
  final VoidCallback onEliminar;
  final VoidCallback? onVerProducto; // null si no tiene producto

  const _NotificationCard({
    required this.icono,
    required this.color,
    required this.leida,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.tiempo,
    this.imagenUrl,
    this.precio,
    required this.onTap,
    required this.onEliminar,
    this.onVerProducto,
  });

  bool get _tieneProducto => tipo == 'nuevo_producto' || tipo == 'promocion';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: leida ? Colors.white : color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: leida ? const Color(0xFFEEEEEE) : color.withOpacity(0.25),
            width: leida ? 0.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF69B4), Color(0xFFD81B60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Sweet',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    tiempo,
                    style: TextStyle(
                      fontSize: 11,
                      color: leida ? Colors.grey[400] : color,
                      fontWeight: leida ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEliminar,
                    child: Icon(Icons.close, size: 15, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),

            // ── Título + mensaje ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: leida
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: leida ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                      ),
                      if (!leida)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mensaje,
                    style: TextStyle(
                      fontSize: 12,
                      color: leida ? Colors.grey[500] : Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Preview producto ──
            if (_tieneProducto) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: color.withOpacity(0.15),
                          child: imagenUrl != null && imagenUrl!.isNotEmpty
                              ? Image.network(
                                  imagenUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(icono, color: color, size: 24),
                                )
                              : Icon(icono, color: color, size: 24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (precio != null)
                              Text(
                                'Bs. ${(precio as num).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD81B60),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '¡Nuevo!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Botones ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEliminar,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ignorar',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      // 👇 si tiene producto navega, si no solo marca leída
                      onPressed: onVerProducto ?? onTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: const Color(0xFFFF69B4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        onVerProducto != null ? 'Ver producto →' : 'Ver más →',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
