import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

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
                  'MiTienda',
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
            Icons.dashboard_outlined,
            'Inicio',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          item(
            Icons.admin_panel_settings,
            'Admins',
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          item(
            Icons.people_outline,
            'Clientes',
            onTap: () => Navigator.pop(context),
          ),
          item(
            Icons.shopping_cart_outlined,
            'Ventas',
            onTap: () => Navigator.pop(context),
          ),
          item(
            Icons.bar_chart_outlined,
            'Reportes',
            onTap: () {
              Navigator.pop(context);
              context.go('/admin2?tab=reportes');
            },
          ),

          const Spacer(),
          const Divider(),
          item(Icons.settings, 'Configuración'),
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
                await Supabase.instance.client.auth.signOut();

                if (!context.mounted) return;

                context.go('/login'); // redirección
              }
            },
          ),
        ],
      ),
    );
  }
}
