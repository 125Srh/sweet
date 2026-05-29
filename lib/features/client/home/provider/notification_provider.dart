import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _notificaciones = [];
  bool _cargando = false;

  List<Map<String, dynamic>> get notificaciones => _notificaciones;
  bool get cargando => _cargando;
  int get noLeidas => _notificaciones.where((n) => n['leida'] == false).length;

  Future<void> cargar() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _cargando = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('notificaciones_cliente')
          .select('''
            *,
            producto (
              nombre,
              imagen_url,
              precio
            )
          ''')
          .eq('usuario_id', userId)
          .order('creada_en', ascending: false)
          .limit(30);

      _notificaciones = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error cargando notificaciones: $e');
    }

    _cargando = false;
    notifyListeners();
  }

  Future<void> marcarLeida(String id) async {
    try {
      await _supabase
          .from('notificaciones_cliente')
          .update({'leida': true})
          .eq('id', id);

      final index = _notificaciones.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notificaciones[index] = {..._notificaciones[index], 'leida': true};
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error marcando leída: $e');
    }
  }

  Future<void> marcarTodasLeidas() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('notificaciones_cliente')
          .update({'leida': true})
          .eq('usuario_id', userId)
          .eq('leida', false);

      _notificaciones = _notificaciones
          .map((n) => {...n, 'leida': true})
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error marcando todas leídas: $e');
    }
  }

  Future<void> eliminar(String id) async {
    try {
      await _supabase.from('notificaciones_cliente').delete().eq('id', id);

      _notificaciones.removeWhere((n) => n['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error eliminando notificación: $e');
    }
  }
}
