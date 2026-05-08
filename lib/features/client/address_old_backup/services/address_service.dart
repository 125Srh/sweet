import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddressService {
  // Guardar dirección en SharedPreferences
  Future<bool> saveAddress(Map<String, dynamic> address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_address', jsonEncode(address));
      return true;
    } catch (e) {
      print('Error guardando dirección: $e');
      return false;
    }
  }

  // Obtener dirección guardada
  Future<Map<String, dynamic>?> getSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressString = prefs.getString('user_address');
      
      if (addressString != null) {
        return jsonDecode(addressString);
      }
      return null;
    } catch (e) {
      print('Error cargando dirección: $e');
      return null;
    }
  }

  // Eliminar dirección guardada
  Future<bool> deleteAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_address');
      return true;
    } catch (e) {
      print('Error eliminando dirección: $e');
      return false;
    }
  }
}