import 'package:flutter/material.dart';
import '../services/address_service_supabase.dart';
//import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressServiceSupabase _addressService = AddressServiceSupabase();
  //final AddressService _addressService = AddressService();////
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _savedAddress;
  
  // Controladores para el formulario
  final formKey = GlobalKey<FormState>();
  final direccionController = TextEditingController();
  final referenciasController = TextEditingController();
  final celularController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get savedAddress => _savedAddress;

  // Validar formulario completo
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Guardar dirección
  Future<bool> guardarDireccion() async {
    if (!validateForm()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final addressData = {
        'direccion': direccionController.text.trim(),
        'referencias': referenciasController.text.trim(),
        'celular': celularController.text.trim(),
      };

      final success = await _addressService.saveAddress(addressData);
      
      if (success) {
        _savedAddress = addressData;
        _error = null;
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar formulario
  void limpiarFormulario() {
    direccionController.clear();
    referenciasController.clear();
    celularController.clear();
    _error = null;
    notifyListeners();
  }

  // Cargar dirección guardada previamente
  Future<void> cargarDireccionGuardada() async {
    _isLoading = true;
    notifyListeners();

    try {
      final saved = await _addressService.getSavedAddress();
      if (saved != null) {
        _savedAddress = saved;
        direccionController.text = saved['direccion'] ?? '';
        referenciasController.text = saved['referencias'] ?? '';
        celularController.text = saved['celular'] ?? '';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    direccionController.dispose();
    referenciasController.dispose();
    celularController.dispose();
    super.dispose();
  }
}