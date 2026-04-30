import 'package:flutter/material.dart';
import 'package:sweet/features/admin/home/providers/admin_provider.dart';
import '../widgets/admin_form.dart';

class AdminList extends StatelessWidget {
  final AdminsProvider provider;

  const AdminList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.filteredProductos.isEmpty) {
      return const Center(child: Text('No hay productos registrados'));
    }

    return ListView.builder(
      itemCount: provider.filteredProductos.length,
      itemBuilder: (_, i) {
        final producto = provider.filteredProductos[i];

        return ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: Text(producto['nombre'] ?? ''),
          subtitle: Text(producto['descripcion'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminForm(producto: producto),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  provider.eliminarProducto(producto['id'].toString());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
