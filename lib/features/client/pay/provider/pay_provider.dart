import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/pay_service.dart';

class PayProvider extends ChangeNotifier {
  bool _processing = false;
  String? _errorMessage;
  String? _successMessage;

  bool get processing => _processing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  bool validarTarjeta(String numero) {
    final soloNumeros = numero.replaceAll(RegExp(r'\s+'), '');
    return soloNumeros.length == 16 && int.tryParse(soloNumeros) != null;
  }

  Future<bool> procesarPago({
    required double subtotal,
    required double envio,
    required double total,
    required String direccion,
    required String referencia,
    required String celular,
    required String metodoPago,
    required String tarjetaNumero,
    required List<Map<String, dynamic>> productos,
  }) async {
    if (_userId == null) {
      _errorMessage = 'Debes iniciar sesión para continuar.';
      notifyListeners();
      return false;
    }

    if (_processing) return false;

    if (metodoPago == 'tarjeta_simulada') {
      if (!validarTarjeta(tarjetaNumero)) {
        _errorMessage = 'Número de tarjeta inválido. Debe tener 16 dígitos.';
        notifyListeners();
        return false;
      }
    }

    _processing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // 1. Crear el pedido
      final pedidoId = await PayService.crearPedido(
        usuarioId: _userId!,
        subtotal: subtotal,
        envio: envio,
        total: total,
        direccion: direccion,
        referencia: referencia,
        celular: celular,
        metodoPago: metodoPago,
        productos: productos,
      );

      // 2. Vaciar el carrito
      await PayService.vaciarCarrito(_userId!);

      // 3. Obtener nombre del cliente
      final usuarioRes = await Supabase.instance.client
          .from('usuario')
          .select('nombre, apellido')
          .eq('id', _userId!)
          .maybeSingle();

      final nombre = usuarioRes != null
          ? '${usuarioRes['nombre'] ?? ''} ${usuarioRes['apellido'] ?? ''}'.trim()
          : 'Cliente';

      // 4. Crear notificación de venta usando solo los campos que
      //    existen en tu tabla notificaciones
      try {
        await Supabase.instance.client.from('notificaciones').insert({
          'tipo': 'nueva_venta',
          'titulo': 'Nueva venta realizada',
          'mensaje': '$nombre realizó un pedido por Bs. ${total.toStringAsFixed(2)}',
          'leida': false,
        });
        print(' Notificación de venta creada');
      } catch (e) {
        // No interrumpir el flujo si falla la notificación
        print(' Error creando notificación de venta: $e');
      }

      _successMessage = '¡Pago exitoso! Pedido #${pedidoId.substring(0, 8)}';
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Error al procesar el pago: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _processing = false;
      notifyListeners();
    }
  }
}