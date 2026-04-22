import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterService {
  final _client = Supabase.instance.client;
  Future<void> register({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;

      if (userId == null) {
        throw Exception('No se pudo crear usuario en auth');
      }

      await _client.from('usuario').insert({
        'id': userId,
        'nombre': data['nombre'],
        'apellido': data['apellido'],
        'email': email,
        'telefono': data['telefono'],
        'direccion': data['direccion'],
        'rol': data['rol'] ?? 'cliente',
        'activo': true,
      });
      print("👉 DATA RECIBIDO: $data");
      print("👉 ROL RECIBIDO: ${data['rol']}");

      print("✅ REGISTRO EXITOSO: $email");
    } on AuthException catch (e) {
      print("❌ AUTH ERROR: ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ ERROR GENERAL: $e");
      rethrow;
    }
  }
}
