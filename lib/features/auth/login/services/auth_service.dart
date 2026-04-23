import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final auth = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print("✅ LOGIN AUTH OK: ${auth.user?.email}");

      final userId = auth.user?.id;
      if (userId == null) throw Exception('Usuario no encontrado');

      final userData = await _client
          .from('usuario')
          .select('rol, activo')
          .eq('id', userId)
          .maybeSingle();

      print("✅ USER DATA: $userData");
      print("👉 USER ID AUTH: $userId");

      if (userData == null) {
        throw Exception('No existe usuario en tabla usuario');
      }
      return {"rol": userData['rol'], "activo": userData['activo']};
    } on AuthException catch (e) {
      // 🔥 ESTE ES EL IMPORTANTE
      print("❌ AUTH ERROR: ${e.message}");
      print("❌ STATUS: ${e.statusCode}");
      throw Exception(e.message);
    } catch (e) {
      print("❌ ERROR GENERAL: $e");

      rethrow;
    }
  }
}
