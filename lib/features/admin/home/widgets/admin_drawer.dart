import 'package:flutter/material.dart';

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
        onTap: () {},
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

          item(Icons.dashboard_outlined, 'Inicio'),
          item(Icons.admin_panel_settings, 'Admins', selected: true),
          item(Icons.people_outline, 'Clientes'),
          item(Icons.shopping_cart_outlined, 'Ventas'),
          item(Icons.bar_chart_outlined, 'Reportes'),

          const Spacer(),
          const Divider(),
          item(Icons.settings, 'Configuración'),
          item(Icons.logout, 'Cerrar Sesión', color: Colors.red),
        ],
      ),
    );
  }
}
