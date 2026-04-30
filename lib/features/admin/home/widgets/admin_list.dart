import 'package:flutter/material.dart';
import '../providers/admin_provider.dart';

class AdminList extends StatelessWidget {
  final AdminsProvider provider;

  const AdminList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.filteredAdmins.isEmpty) {
      return const Center(child: Text('No hay admins registrados'));
    }

    return ListView.builder(
      itemCount: provider.filteredAdmins.length,
      itemBuilder: (_, i) {
        final admin = provider.filteredAdmins[i];

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(admin['nombre'] ?? ''),
          subtitle: Text(admin['codigo'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {},
          ),
        );
      },
    );
  }
}
