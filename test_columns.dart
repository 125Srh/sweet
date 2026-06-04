import 'package:supabase/supabase.dart';
import 'dart:convert';

void main() async {
  final supabase = SupabaseClient(
    'https://olknfwrgwfxufjmrrdpk.supabase.co',
    'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce',
  );

  try {
    final response = await supabase
        .from('producto')
        .select()
        .limit(1);

    if (response.isNotEmpty) {
        print(response.first.keys.toList());
    } else {
        print('No hay productos');
    }
  } catch (e) {
    print('Error: $e');
  }
}
