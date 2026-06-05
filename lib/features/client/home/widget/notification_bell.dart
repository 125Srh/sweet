import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sweet/features/client/home/provider/notification_provider.dart';
import 'package:sweet/features/client/home/widget/notification_panel.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _panelAbierto = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    Future.microtask(() {
      context.read<NotificationProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _cerrarPanel();
    _animController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    if (_panelAbierto) {
      _cerrarPanel();
    } else {
      _abrirPanel();
    }
  }

  void _abrirPanel() {
    final provider = context.read<NotificationProvider>();

    _overlayEntry = OverlayEntry(
      builder: (ctx) => AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          alignment: Alignment.topRight,
          child: child,
        ),
        child: NotificationPanel(
          layerLink: _layerLink,
          notificaciones: provider.notificaciones,
          noLeidas: provider.noLeidas,
          onClose: _cerrarPanel,
          onMarcarLeida: (id) async {
            await provider.marcarLeida(id);
          },
          onEliminar: (id) {
            provider.eliminar(id);
          },
          onMarcarTodas: () {
            provider.marcarTodasLeidas();
          },
          onVerProducto: (notif) {
            _cerrarPanel();
            final producto = notif['producto'];
            if (producto != null) {
              final productData = {
                'id': notif['producto_id'],
                'nombre': producto['nombre'],
                'imagen_url': producto['imagen_url'],
                'precio': producto['precio'],
                'stock': producto['stock'],
                'descripcion': producto['descripcion'], // ✅
              };
              context.push(
                '/client/producto/${notif['producto_id']}',
                extra: productData,
              );
            }
          },
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
    setState(() => _panelAbierto = true);
  }

  void _cerrarPanel() {
    _animController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    if (mounted) setState(() => _panelAbierto = false);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return IconButton(
            onPressed: _togglePanel,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  _panelAbierto
                      ? Icons.notifications
                      : Icons.notifications_none,
                  color: _panelAbierto
                      ? const Color(0xFFD81B60)
                      : const Color(0xFFFF69B4),
                ),
                if (provider.noLeidas > 0)
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
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          provider.noLeidas > 99
                              ? '99+'
                              : '${provider.noLeidas}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
