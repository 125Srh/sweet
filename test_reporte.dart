import 'package:supabase/supabase.dart';
import 'dart:convert';

void main() async {
  final supabase = SupabaseClient(
    'https://olknfwrgwfxufjmrrdpk.supabase.co',
    'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce',
  );

  try {
    final response = await supabase
        .from('pedido')
        .select()
        .or('estado.eq.completado,estado.eq.pendiente')
        .order('created_at', ascending: false);

    print('Total pedidos obtenidos: ${response.length}');
    for (var r in response) {
      print(r);
      try {
        final id = r['id'].toString();
        final pedidoId = (r['pedido_id'] ?? r['id']).toString();
        final fecha = DateTime.parse(r['created_at'] ?? r['fecha_creacion']);
        final subtotal = (r['subtotal'] as num?)?.toDouble() ?? 0;
        final costoEnvio = (r['costo_envio'] as num?)?.toDouble() ?? 0;
        final total = (r['total'] as num?)?.toDouble() ?? 0;
        final metodoPago = r['metodo_pago'] ?? '';
        final estado = r['estado'] ?? 'pendiente';
        print('Parsed: ID: $id, Total: $total, Fecha: $fecha');
      } catch (e) {
        print('ERROR parseando fila: $e');
      }
    }
  } catch (e) {
    print('Error_catch: $e');
  }
}
