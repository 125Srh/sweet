import 'package:flutter/material.dart';
import '../services/register_service.dart';

class RegisterProvider extends ChangeNotifier {
  final RegisterService _service = RegisterService();

  bool isLoading = false;

  Future<String?> register({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.register(
        email: email,
        password: password,
        data: data,
      );

      return null; // éxito
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}