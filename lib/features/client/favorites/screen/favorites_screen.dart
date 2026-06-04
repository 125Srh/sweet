import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/favorites_service.dart';
import '../../cart/provider/cart_provider.dart';
import '../../cart/widget/add_to_cart_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favoritos = [];
  bool _loading = true;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadFavoritos();
  }

  Future<void> _loadFavoritos() async {
    if (_userId == null) return;
    setState(() => _loading = true);
    try {
      final data = await FavoritesService.getFavoritos(_userId!);
      if (mounted) setState(() { _favoritos = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quitar(String productoId, String nombre) async {
    if (_userId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Quitar de favoritos?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
        content: Text('¿Deseas quitar "$nombre" de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Quitar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FavoritesService.quitar(_userId!, productoId);
      await _loadFavoritos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$nombre quitado de favoritos'),
          backgroundColor: Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFD81B60)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          const Icon(Icons.favorite, color: Color(0xFFFF69B4)),
          const SizedBox(width: 10),
          const Text('Mis Favoritos',
              style: TextStyle(
                  color: Color(0xFFD81B60),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          if (_favoritos.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${_favoritos.length}',
                  style: const TextStyle(
                      color: Color(0xFFFF69B4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
          : RefreshIndicator(
              color: const Color(0xFFFF69B4),
              onRefresh: _loadFavoritos,
              child: _favoritos.isEmpty
                  ? _emptyFavorites()
                  : _favoritosList(),
            ),
    );
  }

  // ── Sin favoritos ──────────────────────────────────────────
  Widget _emptyFavorites() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border,
                  size: 55, color: Color(0xFFFF69B4)),
            ),
            const SizedBox(height: 20),
            const Text('No tienes favoritos aún',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD81B60))),
            const SizedBox(height: 8),
            const Text('Marca productos con ❤️ para guardarlos aquí',
                style: TextStyle(fontSize: 14, color: Colors.black45),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.store_outlined, color: Colors.white),
              label: const Text('Explorar productos',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 3,
              ),
            ),
          ],
        ),
      );

  // ── Lista de favoritos ─────────────────────────────────────
  Widget _favoritosList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 14) / 2;
    final imageHeight = cardWidth * 0.75;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _favoritos.length,
      itemBuilder: (_, i) {
        final fav      = _favoritos[i];
        final producto = fav['producto'] as Map<String, dynamic>;
        final prodId   = producto['id'] as String;
        final nombre   = producto['nombre'] as String;
        final precio   = (producto['precio'] as num).toDouble();
        final imagen   = producto['imagen_url'] as String?;
        final stock    = producto['stock'] as int;
        final marca    = producto['marca']?['nombre'] as String? ?? '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF69B4).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              Stack(children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: imagen != null && imagen.isNotEmpty
                        ? Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.spa,
                                    size: 40, color: Color(0xFFFF69B4))),
                          )
                        : const Center(
                            child: Icon(Icons.spa,
                                size: 40, color: Color(0xFFFF69B4))),
                  ),
                ),
                // Botón quitar de favoritos
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _quitar(prodId, nombre),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite,
                          color: Color(0xFFFF69B4), size: 18),
                    ),
                  ),
                ),
                // Badge sin stock
                if (stock <= 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Sin stock',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ]),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (marca.isNotEmpty)
                        Text(marca,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      const Spacer(),
                      Text('Bs. ${precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Color(0xFFD81B60),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 6),
                      AddToCartButton(
                        productoId: prodId,
                        productoNombre: nombre,
                        precio: precio,
                        stock: stock,
                        compact: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Widget FavoriteButton reutilizable ────────────────────────
class FavoriteButton extends StatefulWidget {
  final String productoId;
  final double size;
  const FavoriteButton({super.key, required this.productoId, this.size = 38});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _esFavorito = false;
  bool _loading = true;
  late AnimationController _heartCtrl;
  late Animation<double> _heartAnim;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _heartAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
        CurvedAnimation(parent: _heartCtrl, curve: Curves.elasticOut));
    _checkFavorito();
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFavorito() async {
    if (_userId == null) {
      setState(() => _loading = false);
      return;
    }
    final es = await FavoritesService.esFavorito(_userId!, widget.productoId);
    if (mounted) setState(() { _esFavorito = es; _loading = false; });
  }

  Future<void> _toggle() async {
    if (_userId == null) return;
    await _heartCtrl.forward();
    await _heartCtrl.reverse();
    final ahora = await FavoritesService.toggle(_userId!, widget.productoId);
    if (mounted) setState(() => _esFavorito = ahora);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ahora ? '❤️ Agregado a favoritos' : 'Quitado de favoritos'),
        backgroundColor: ahora ? const Color(0xFFFF69B4) : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
          width: widget.size,
          height: widget.size,
          child: const CircularProgressIndicator(
              strokeWidth: 1.5, color: Color(0xFFFF69B4)));
    }
    return GestureDetector(
      onTap: _toggle,
      child: ScaleTransition(
        scale: _heartAnim,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _esFavorito
                ? const Color(0xFFFF69B4).withOpacity(0.15)
                : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(
            _esFavorito ? Icons.favorite : Icons.favorite_border,
            color: const Color(0xFFFF69B4),
            size: widget.size * 0.52,
          ),
        ),
      ),
    );
  }
}