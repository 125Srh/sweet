import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://olknfwrgwfxufjmrrdpk.supabase.co',
    'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce',
  );

  try {
    print('Testing descontar_stock RPC...');
    final response = await supabase.rpc('descontar_stock', params: {
      'p_producto_id': '00000000-0000-0000-0000-000000000000',
      'p_cantidad': 0,
    });
    print('RPC Success, result: $response');
  } catch (e) {
    print('RPC Error: $e');
  }
}
