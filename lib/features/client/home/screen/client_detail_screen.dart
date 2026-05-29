import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sweet/features/client/cart/provider/cart_provider.dart';
import 'package:sweet/features/client/favorites/service/favorites_service.dart';
import 'package:sweet/features/client/home/widget/swipeToCarButton.dart';

class ClientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ClientDetailScreen({super.key, required this.product});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  bool _esFavorito = false;
  bool _loadingFav = true;

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _checkFavorito();
  }

  Future<void> _checkFavorito() async {
    if (_userId == null) {
      setState(() => _loadingFav = false);
      return;
    }
    final prodId = widget.product['id']?.toString() ?? '';
    final es = await FavoritesService.esFavorito(_userId!, prodId);
    if (mounted)
      setState(() {
        _esFavorito = es;
        _loadingFav = false;
      });
  }

  Future<void> _toggleFavorito() async {
    if (_userId == null) return;
    final prodId = widget.product['id']?.toString() ?? '';
    setState(() => _loadingFav = true);
    try {
      final ahora = await FavoritesService.toggle(_userId!, prodId);
      if (mounted) {
        setState(() {
          _esFavorito = ahora;
          _loadingFav = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ahora ? '❤️ Agregado a favoritos' : 'Quitado de favoritos',
            ),
            backgroundColor: ahora ? const Color(0xFFFF69B4) : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFav = false);
    }
  }

  Future<void> _agregarAlCarrito() async {
    final prodId = widget.product['id']?.toString() ?? '';
    final precio = (widget.product['precio'] as num?)?.toDouble() ?? 0.0;
    final nombre = widget.product['nombre']?.toString() ?? '';

    try {
      await context.read<CartProvider>().agregar(
        productoId: prodId,
        precioUnitario: precio,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🛒 $nombre agregado al carrito 💖'),
            backgroundColor: const Color(0xFFD81B60),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.product['imagen_url'];
    final name = widget.product['nombre'];
    final price = widget.product['precio'];
    final description = widget.product['descripcion'] ?? 'Sin descripción';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      // 👇 Botón comprar fijo abajo, no se mueve al hacer scroll
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SizedBox(
          width: double.infinity,
          child: SwipeToCartButton(onConfirmed: _agregarAlCarrito),
        ),
      ),
      body: SingleChildScrollView(
        // 👈 FIX: scroll para evitar overflow
        child: Column(
          children: [
            // 🔥 IMAGEN + GRADIENTE + BACK + FAVORITO
            Stack(
              children: [
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: image != null && image != ''
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.image, size: 100)),
                        )
                      : const Center(child: Icon(Icons.spa, size: 80)),
                ),

                // 💕 GRADIENTE ROSADO
                Container(
                  height: 450,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFF48FB1).withOpacity(0.3),
                        const Color(0xFFF48FB1).withOpacity(0.6),
                      ],
                      stops: const [0.6, 0.8, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // 🔙 BOTÓN BACK
                Positioned(
                  top: 40,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFD81B60),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // ❤️ BOTÓN FAVORITO
                Positioned(
                  top: 40,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: _loadingFav
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFF69B4),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              _esFavorito
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: const Color(0xFFFF69B4),
                            ),
                            onPressed: _toggleFavorito,
                          ),
                  ),
                ),
              ],
            ),

            // 🔥 CONTENIDO
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏷️ NOMBRE
                    Text(
                      name ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ⭐ RATING
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 5),
                        Text('5.0', style: TextStyle(color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // 💲 PRECIO
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 26,
                        color: Color(0xFFD81B60),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📝 DESCRIPCIÓN
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
