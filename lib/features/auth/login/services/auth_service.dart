import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final auth = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = auth.user?.id;
    if (userId == null) throw Exception('Usuario no encontrado');

    final userData = await _client
        .from('usuario')
        .select('rol, activo')
        .eq('id', userId)
        .single();

    // ✔ aquí puedes devolver limpio (opcional pero recomendado)
    return {"rol": userData['rol'], "activo": userData['activo']};
  }
}
