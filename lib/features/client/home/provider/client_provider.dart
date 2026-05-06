import 'package:flutter/material.dart';
import 'package:sweet/features/client/home/service/client_service.dart';

class ClientProvider extends ChangeNotifier {
  final ClientService _service = ClientService();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];

  bool isLoading = false;

  String? selectedCategoryId;

  // 🔥 Cargar inicial
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getCategories(),
      _service.getFeaturedProducts(),
    ]);

    categories = results[0];
    products = results[1];

    isLoading = false;
    notifyListeners();
  }

  // 🔥 Filtrar por categoría
  Future<void> filterByCategory(String categoryId) async {
    isLoading = true;
    selectedCategoryId = categoryId;
    notifyListeners();

    products = await _service.getProductsByCategory(categoryId);

    isLoading = false;
    notifyListeners();
  }

  // 🔥 Reset (destacados)
  Future<void> resetProducts() async {
    isLoading = true;
    selectedCategoryId = null;
    notifyListeners();

    products = await _service.getFeaturedProducts();

    isLoading = false;
    notifyListeners();
  }
}
