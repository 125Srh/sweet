import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_model.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getCurrentUser() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromMap(response);
  }
}
