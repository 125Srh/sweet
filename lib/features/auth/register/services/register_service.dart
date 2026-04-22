import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterService {
  final _client = Supabase.instance.client;

  Future<void> register({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Error al crear usuario');
    }

    await _client.from('usuario').insert({
      'identificación': userId,
      ...data,
    });
  }
}