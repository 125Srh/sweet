import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class AdminSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminsProvider>();
    const pinkColor = Color(0xFFFF69B4);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (v) => provider.searchQuery = v,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: pinkColor),
          ),
        ),
      ),
    );
  }
}
