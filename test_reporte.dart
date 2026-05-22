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
        .limit(2);

    for (var r in response) {
      print(jsonEncode(r));
    }
  } catch (e) {
    print('Error_catch: $e');
  }
}
