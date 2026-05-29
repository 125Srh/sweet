// lib/features/admin/home/widgets/admin_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/admin_clients_screen.dart';
import '../screens/admin_notifications_screen.dart';
import '../screens/admin_orders_screen.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;

  const AdminDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color.fromARGB(255, 255, 19, 98);

    Widget item(
      IconData icon,
      String title, {
      bool selected = false,
      Color? color,
      VoidCallback? onTap,
    }) {
      return ListTile(
        leading: Icon(
          icon,
          color: selected ? pinkColor : color ?? Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? pinkColor : color ?? Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: selected ? pinkColor.withOpacity(0.1) : null,
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

          // índice 0
          item(
            Icons.inventory_2,
            'Productos',
            selected: selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),

          // índice 1
          item(
            Icons.people_outline,
            'Clientes',
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminClientsScreen()),
              );
            },
          ),

          // índice 2
          item(
            Icons.notifications_outlined,
            'Notificaciones de ventas',
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminNotificationsScreen(),
                ),
              );
            },
          ),

          // índice 3
          item(
            Icons.bar_chart_outlined,
            'Reportes',
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              context.go('/reportes');
            },
          ),

          // índice 4
          item(
            Icons.shopping_bag_outlined,
            'Gestionar Pedidos',
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              );
            },
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

              if (confirmar == true) {
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 100));
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  context.go('/login');
                } catch (e) {
                  debugPrint("❌ [DRAWER ERROR] Falló al hacer signOut: $e");
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
