import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  static final _db = Supabase.instance.client;

  // ── Obtener todos los favoritos del usuario ──────────────────
  static Future<List<Map<String, dynamic>>> getFavoritos(String usuarioId) async {
    // La tabla se llama "recomendacion" en tu BD
    // pero si tienes una tabla favorito separada úsala
    // Aquí usamos la tabla que aparece en tu BD: recomendacion
    // Si tienes tabla favorito, cambia 'recomendacion' por 'favorito'
    final res = await _db
        .from('recomendacion')
        .select('''
          id,
          motivo,
          created_at,
          producto:producto_id (
            id,
            nombre,
            descripcion,
            precio,
            imagen_url,
            stock,
            marca:marca_id (nombre),
            categoria:categoria_id (nombre)
          )
        ''')
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // ── Verificar si un producto está en favoritos ───────────────
  static Future<bool> esFavorito(String usuarioId, String productoId) async {
    final res = await _db
        .from('recomendacion')
        .select('id')
        .eq('usuario_id', usuarioId)
        .eq('producto_id', productoId)
        .maybeSingle();
    return res != null;
  }

  // ── Agregar a favoritos ──────────────────────────────────────
  static Future<void> agregar(String usuarioId, String productoId) async {
    await _db.from('recomendacion').insert({
      'usuario_id': usuarioId,
      'producto_id': productoId,
      'motivo': 'favorito',
    });
  }

  // ── Quitar de favoritos ──────────────────────────────────────
  static Future<void> quitar(String usuarioId, String productoId) async {
    await _db
        .from('recomendacion')
        .delete()
        .eq('usuario_id', usuarioId)
        .eq('producto_id', productoId);
  }

  // ── Toggle favorito ──────────────────────────────────────────
  static Future<bool> toggle(String usuarioId, String productoId) async {
    final ya = await esFavorito(usuarioId, productoId);
    if (ya) {
      await quitar(usuarioId, productoId);
      return false;
    } else {
      await agregar(usuarioId, productoId);
      return true;
    }
  }
}