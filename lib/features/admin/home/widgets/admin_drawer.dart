// lib/features/admin/home/widgets/admin_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Índices del menú lateral admin:
/// 0 Productos · 1 Clientes · 2 Notificaciones · 3 Reportes · 4 Pedidos
class AdminDrawer extends StatelessWidget {
  final int selectedIndex;

  const AdminDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xFFFF69B4);

    void irA(String ruta) {
      Navigator.pop(context);
      context.go(ruta);
    }

    Widget item(
      IconData icon,
      String title, {
      bool selected = false,
      Color? color,
      VoidCallback? onTap,
    }) {
      final itemColor = color ?? pinkColor;
      return ListTile(
        leading: Icon(
          icon,
          color: itemColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        tileColor: selected ? pinkColor.withOpacity(0.12) : null,
        onTap: onTap,
      );
    }

    return Drawer(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: pinkColor,
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.store, size: 50),
                ),
                SizedBox(height: 10),
                Text(
                  'Sweet',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          item(
            Icons.inventory_2,
            'Productos',
            selected: selectedIndex == 0,
            onTap: () => irA('/admin'),
          ),
          item(
            Icons.people_outline,
            'Clientes',
            selected: selectedIndex == 1,
            onTap: () => irA('/admin/clientes'),
          ),
          item(
            Icons.notifications_outlined,
            'Notificaciones de ventas',
            selected: selectedIndex == 2,
            onTap: () => irA('/admin/notificaciones'),
          ),
          item(
            Icons.bar_chart_outlined,
            'Reportes',
            selected: selectedIndex == 3,
            onTap: () => irA('/reportes'),
          ),
          item(
            Icons.shopping_bag_outlined,
            'Gestionar Pedidos',
            selected: selectedIndex == 4,
            onTap: () => irA('/admin/pedidos'),
          ),

          const Spacer(),
          const Divider(),

          item(
            Icons.logout,
            'Cerrar Sesión',
            color: Colors.red,
            onTap: () async {
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

              if (confirmar == true && context.mounted) {
                Navigator.pop(context);
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  context.go('/login');
                } catch (e) {
                  debugPrint('❌ [DRAWER] Error al cerrar sesión: $e');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
