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
          prefixIcon: const Icon(Icons.search, color: pinkColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: pinkColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD81B60), width: 1.5),
          ),
        ),
      ),
    );
  }
}
