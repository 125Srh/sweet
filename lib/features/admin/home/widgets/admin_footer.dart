// lib/features/admin/home/widgets/admin_footer.dart
import 'package:flutter/material.dart';
import '../providers/admin_provider.dart';

class AdminFooter extends StatelessWidget {
  final AdminsProvider provider;

  const AdminFooter({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${provider.productos.length} productos',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          Text(
            'Sweet v1.0',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
