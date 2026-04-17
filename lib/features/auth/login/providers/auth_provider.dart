import '../services/auth_service.dart';
class AuthProvider {
   final _service = AuthService();

  Future<String> login(String email, String password) async {
    final data = await _service.login(email, password);

    final rol = data['rol'] as String;
    final activo = data['activo'] as bool;

    if (!activo) throw Exception('Cuenta desactivada');

    return rol;
  }
}