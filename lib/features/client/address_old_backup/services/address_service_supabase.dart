import 'package:supabase_flutter/supabase_flutter.dart';

class AddressServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<bool> saveAddress(Map<String, dynamic> address) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      
      final pedidoExistente = await _supabase
          .from('pedido')
          .select()
          .eq('usuario_id', user.id)
          .eq('estado', 'pendiente')
          .maybeSingle();
      
      if (pedidoExistente == null) {
        await _supabase.from('pedido').insert({
          'usuario_id': user.id,
          'direccion_entrega': address['direccion'],
          'notas': address['referencias'],
          'telefono_receptor': address['celular'],
          'estado': 'pendiente',
          'subtotal': 0,
          'total': 0,
        });
      } else {
        await _supabase.from('pedido').update({
          'direccion_entrega': address['direccion'],
          'notas': address['referencias'],
          'telefono_receptor': address['celular'],
        }).eq('id', pedidoExistente['id']);
      }
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> getSavedAddress() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      final pedido = await _supabase
          .from('pedido')
          .select()
          .eq('usuario_id', user.id)
          .eq('estado', 'pendiente')
          .maybeSingle();
      
      if (pedido == null) return null;
      
      return {
        'direccion': pedido['direccion_entrega'] ?? '',
        'referencias': pedido['notas'] ?? '',
        'celular': pedido['telefono_receptor'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}