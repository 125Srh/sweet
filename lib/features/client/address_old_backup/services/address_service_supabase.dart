import 'package:supabase_flutter/supabase_flutter.dart';

class AddressServiceSupabase {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<bool> saveAddress(Map<String, dynamic> address) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'direccion': address['direccion'],
            'referencias': address['referencias'],
            'celular': address['celular'],
          },
        ),
      );
      
      return true;
    } catch (e) {
      print('Error guardando dirección en Supabase Auth: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> getSavedAddress() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      // 1. Intentar cargar desde los metadatos del usuario (almacenamiento permanente real)
      final metadata = user.userMetadata;
      if (metadata != null && metadata.containsKey('direccion') && metadata['direccion'].toString().isNotEmpty) {
        return {
          'direccion': metadata['direccion'] ?? '',
          'referencias': metadata['referencias'] ?? '',
          'celular': metadata['celular'] ?? '',
        };
      }
      
      // 2. Si no hay en metadatos, buscar en su último pedido para migrar/autocompletar
      final pedidoList = await _supabase
          .from('pedido')
          .select('direccion_entrega, notas, telefono_receptor')
          .eq('usuario_id', user.id)
          .order('id', ascending: false)
          .limit(1);
      
      if (pedidoList.isNotEmpty) {
        final pedido = pedidoList.first;
        final dbAddress = {
          'direccion': pedido['direccion_entrega'] ?? '',
          'referencias': pedido['notas'] ?? '',
          'celular': pedido['telefono_receptor'] ?? '',
        };
        // Migrar a metadatos para la próxima vez
        await saveAddress(dbAddress);
        return dbAddress;
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo dirección guardada de Supabase: $e');
      return null;
    }
  }
}