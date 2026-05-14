// lib/features/admin/home/widgets/admin_appbar.dart
import 'package:flutter/material.dart';
import '../service/admin_service.dart';

// ══════════════════════════════════════════════════════════════
// AppBar principal
// ══════════════════════════════════════════════════════════════
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color.fromARGB(255, 255, 19, 98);

    return AppBar(
      backgroundColor: pinkColor,
      elevation: 0,
      title: const Text(
        'MiTienda',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        // ✅ Se eliminaron los íconos de impresión y configuración
        const _NotificacionesBtn(),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ══════════════════════════════════════════════════════════════
// Botón campana
// ══════════════════════════════════════════════════════════════
class _NotificacionesBtn extends StatefulWidget {
  const _NotificacionesBtn();

  @override
  State<_NotificacionesBtn> createState() => _NotificacionesBtnState();
}

class _NotificacionesBtnState extends State<_NotificacionesBtn> {
  final AdminService _service = AdminService();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _panelAbierto = false;

  List<Map<String, dynamic>> _notificaciones = [];
  int _noLeidas = 0;

  @override
  void initState() {
    super.initState();
    _service.streamNotificaciones().listen((lista) {
      if (!mounted) return;
      setState(() {
        _notificaciones = lista;
        _noLeidas = lista.where((n) => n['leida'] == false).length;
      });
      if (_panelAbierto) _refreshOverlay();
    });
  }

  void _refreshOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _mostrarPanel();
  }

  void _mostrarPanel() {
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _panelAbierto = true);
  }

  void _cerrarPanel() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _panelAbierto = false);
  }

  void _togglePanel() {
    if (_panelAbierto) {
      _cerrarPanel();
    } else {
      _mostrarPanel();
    }
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (ctx) => _NotificacionesPanel(
        layerLink: _layerLink,
        notificaciones: _notificaciones,
        noLeidas: _noLeidas,
        onClose: _cerrarPanel,
        onMarcarLeida: (id) async => await _service.marcarComoLeida(id),
        onEliminar: (id) async => await _service.eliminarNotificacion(id),
        onMarcarTodas: () async => await _service.marcarTodasComoLeidas(),
      ),
    );
  }

  @override
  void dispose() {
    _cerrarPanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        onPressed: _togglePanel,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              _panelAbierto ? Icons.notifications : Icons.notifications_none,
              color: Colors.white,
            ),
            if (_noLeidas > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      _noLeidas > 9 ? '9+' : '$_noLeidas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Panel flotante
// ══════════════════════════════════════════════════════════════
class _NotificacionesPanel extends StatelessWidget {
  final LayerLink layerLink;
  final List<Map<String, dynamic>> notificaciones;
  final int noLeidas;
  final VoidCallback onClose;
  final void Function(String id) onMarcarLeida;
  final void Function(String id) onEliminar;
  final VoidCallback onMarcarTodas;

  const _NotificacionesPanel({
    required this.layerLink,
    required this.notificaciones,
    required this.noLeidas,
    required this.onClose,
    required this.onMarcarLeida,
    required this.onEliminar,
    required this.onMarcarTodas,
  });

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
            child: _PanelContent(
              notificaciones: notificaciones,
              noLeidas: noLeidas,
              onMarcarLeida: onMarcarLeida,
              onEliminar: onEliminar,
              onMarcarTodas: onMarcarTodas,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Contenido visual del panel
// ══════════════════════════════════════════════════════════════
class _PanelContent extends StatelessWidget {
  final List<Map<String, dynamic>> notificaciones;
  final int noLeidas;
  final void Function(String id) onMarcarLeida;
  final void Function(String id) onEliminar;
  final VoidCallback onMarcarTodas;

  const _PanelContent({
    required this.notificaciones,
    required this.noLeidas,
    required this.onMarcarLeida,
    required this.onEliminar,
    required this.onMarcarTodas,
  });

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'stock_bajo':
        return Icons.inventory_2_outlined;
      case 'agotado':
        return Icons.remove_shopping_cart;
      case 'reposicion':
        return Icons.add_shopping_cart;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'stock_bajo':
        return const Color(0xFFE67E22);
      case 'agotado':
        return const Color(0xFFE74C3C);
      case 'reposicion':
        return const Color(0xFF27AE60);
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

  List<TextSpan> _construirMensaje(String mensaje, bool leida, Color color) {
    final regexUnidades = RegExp(r'(.+?) (.+?) de (.+)');
    final matchUnidades = regexUnidades.firstMatch(mensaje);
    if (matchUnidades != null) {
      return [
        TextSpan(text: '${matchUnidades.group(1)} '),
        TextSpan(
          text: matchUnidades.group(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: leida ? Colors.grey[600] : color,
          ),
        ),
        const TextSpan(text: ' de '),
        TextSpan(
          text: matchUnidades.group(3),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ];
    }

    final regexAgotado = RegExp(r'^(.+?) se ha agotado\.(.+)$');
    final matchAgotado = regexAgotado.firstMatch(mensaje);
    if (matchAgotado != null) {
      return [
        TextSpan(
          text: matchAgotado.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(text: ' se ha agotado.'),
        TextSpan(
          text: matchAgotado.group(2),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: leida ? Colors.grey[600] : color,
          ),
        ),
      ];
    }

    return [TextSpan(text: mensaje)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
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
                      color: const Color(0xFFFF1362),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Marcar todas',
                      style: TextStyle(color: Color(0xFFFF69B4), fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          if (notificaciones.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 44,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Todo en orden',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No hay notificaciones pendientes',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: notificaciones.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFF5F5F5),
                ),
                itemBuilder: (ctx, i) {
                  final n = notificaciones[i];
                  final tipo = n['tipo'] ?? 'info';
                  final leida = n['leida'] ?? false;
                  final color = _colorTipo(tipo);
                  final mensaje = n['mensaje'] ?? '';

                  return _NotificacionTile(
                    icono: _iconoTipo(tipo),
                    color: color,
                    leida: leida,
                    tiempo: _formatearTiempo(n['creada_en']),
                    spans: _construirMensaje(mensaje, leida, color),
                    onTap: () => onMarcarLeida(n['id']),
                    onEliminar: () => onEliminar(n['id']),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tile individual
// ══════════════════════════════════════════════════════════════
class _NotificacionTile extends StatelessWidget {
  final IconData icono;
  final Color color;
  final bool leida;
  final String tiempo;
  final List<TextSpan> spans;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _NotificacionTile({
    required this.icono,
    required this.color,
    required this.leida,
    required this.tiempo,
    required this.spans,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: leida ? Colors.transparent : color.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(leida ? 0.07 : 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: leida ? Colors.grey[400] : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: leida ? FontWeight.normal : FontWeight.w600,
                        color: leida ? Colors.grey[600] : Colors.black87,
                        height: 1.4,
                      ),
                      children: spans,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tiempo,
                    style: TextStyle(
                      fontSize: 11,
                      color: leida ? Colors.grey[400] : color,
                      fontWeight: leida ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!leida)
                  Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(bottom: 6, top: 2),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                GestureDetector(
                  onTap: onEliminar,
                  child: Icon(Icons.close, size: 16, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
