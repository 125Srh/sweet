import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://olknfwrgwfxufjmrrdpk.supabase.co',
    'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce'
  );

  try {
    final response = await supabase.from('producto').select('id, nombre, precio_adquisicion');
    print('PRODUCTOS EN LA BASE DE DATOS:');
    for (var p in response) {
      print('- ${p['nombre']}: precio_adquisicion = ${p['precio_adquisicion']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
