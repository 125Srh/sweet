import 'package:flutter/material.dart';

class CheckoutProvider extends ChangeNotifier {
  // Datos del carrito (recibidos desde CartScreen)
  double _subtotal = 0.0;
  int _totalItems = 0;
  List<Map<String, dynamic>> _items = [];
  
  // Datos de dirección (recibidos desde AddressScreen)
  Map<String, dynamic> _direccion = {};
  
  // Datos de pago simulados
  String _metodoPago = 'Efectivo'; // Efectivo, Tarjeta, Transferencia
  double _costoEnvio = 0.0;
  double _total = 0.0;
  
  // Estados
  bool _isLoading = false;
  String? _error;

  // Getters
  double get subtotal => _subtotal;
  int get totalItems => _totalItems;
  List<Map<String, dynamic>> get items => _items;
  Map<String, dynamic> get direccion => _direccion;
  String get metodoPago => _metodoPago;
  double get costoEnvio => _costoEnvio;
  double get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Opciones de envío
  final List<Map<String, dynamic>> opcionesEnvio = [
    {'nombre': 'Envío estándar', 'dias': '3-5 días', 'costo': 15.00},
    {'nombre': 'Envío express', 'dias': '1-2 días', 'costo': 35.00},
    {'nombre': 'Recojo en tienda', 'dias': 'Gratis', 'costo': 0.00},
  ];

  // Métodos de pago simulados
  final List<Map<String, dynamic>> metodosPago = [
    {'nombre': 'Efectivo contra entrega', 'icono': Icons.money, 'descripcion': 'Paga al recibir'},
    {'nombre': 'Tarjeta de crédito/débito', 'icono': Icons.credit_card, 'descripcion': 'Visa, Mastercard, American Express'},
    {'nombre': 'Transferencia bancaria', 'icono': Icons.account_balance, 'descripcion': 'Yape, Plin, BCP, Interbank'},
  ];

  // Inicializar con datos del carrito
  void inicializarCarrito({
    required double subtotal,
    required int totalItems,
    required List<Map<String, dynamic>> items,
  }) {
    _subtotal = subtotal;
    _totalItems = totalItems;
    _items = items;
    _calcularTotal();
    notifyListeners();
  }

  // Establecer dirección
  void setDireccion(Map<String, dynamic> direccion) {
    _direccion = direccion;
    notifyListeners();
  }

  // Cambiar método de pago
  void setMetodoPago(String metodo) {
    _metodoPago = metodo;
    notifyListeners();
  }

  // Cambiar costo de envío
  void setCostoEnvio(double costo) {
    _costoEnvio = costo;
    _calcularTotal();
    notifyListeners();
  }

  // Calcular total
  void _calcularTotal() {
    _total = _subtotal + _costoEnvio;
  }

  // Procesar pago simulado
  Future<bool> procesarPago() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simular procesamiento de 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    // Simular que el pago siempre es exitoso
    final bool exito = true; // En simulación siempre exitoso

    if (exito) {
      // Aquí guardaríamos el pedido en la base de datos
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Error al procesar el pago. Intenta nuevamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Limpiar datos
  void limpiar() {
    _subtotal = 0.0;
    _totalItems = 0;
    _items = [];
    _direccion = {};
    _metodoPago = 'Efectivo';
    _costoEnvio = 0.0;
    _total = 0.0;
    _error = null;
  }
}