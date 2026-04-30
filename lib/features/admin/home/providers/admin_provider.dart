import 'package:flutter/material.dart';

class AdminsProvider extends ChangeNotifier {
  //final SupabaseService _service = SupabaseService();

  List<Map<String, dynamic>> productos = [];
  bool isLoading = true;
  String searchQuery = '';

  Future<void> cargarAdminos() async {
    isLoading = true;
    notifyListeners();

    //productos = await _service.getAdminos();

    isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredAdmins {
    if (searchQuery.isEmpty) return productos;

    return productos
        .where(
          (product) =>
              product['nombre'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              product['codigo'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }
}
