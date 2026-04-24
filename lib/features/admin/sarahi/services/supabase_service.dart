import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getProductos() async {
    try {
      final response = await supabase
          .from('producto')
          .select('*')
          .eq('activo', true)
          .order('nombre');
      return response;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}