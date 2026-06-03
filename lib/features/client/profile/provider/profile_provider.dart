// lib/features/client/profile/provider/profile_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sweet/features/user/model/user_model.dart';// ajusta el import según tu estructura

class ProfileProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> cargar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) throw Exception('No hay sesión activa');

      final data = await _supabase
          .from('usuario')
          .select()
          .eq('id', uid)
          .single();

      _user = UserModel.fromMap(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizar({
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) throw Exception('No hay sesión activa');

      await _supabase.from('usuario').update({
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'telefono': telefono.trim().isEmpty ? null : telefono.trim(),
        'direccion': direccion.trim().isEmpty ? null : direccion.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      await cargar();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}