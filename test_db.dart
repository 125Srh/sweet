import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://olknfwrgwfxufjmrrdpk.supabase.co',
    'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce',
  );

  try {
    print('Testing query on database schema...');
    final res = await supabase.rpc('descontar_stock', params: {
      'p_producto_id': '00000000-0000-0000-0000-000000000000',
      'p_cantidad': 0
    });
    print('RPC descontar_stock call result: $res');
  } catch (e) {
    print('Error testing RPC descontar_stock: $e');
  }
}
