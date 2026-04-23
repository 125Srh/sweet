import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sweet/features/client/home/widget/client_category_item.dart';
import 'package:sweet/features/client/home/widget/client_product_card.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 $feature - ¡Próximamente!'),
        backgroundColor: const Color(0xFFFF69B4),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sweet',
          style: TextStyle(
            color: Color(0xFFD81B60),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFFF69B4),
            ),
            onPressed: () => _showComingSoon(context, 'Carrito de compras'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFFFF69B4)),
            onPressed: () => _showComingSoon(context, 'Perfil de usuario'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF69B4)),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚪 Sesión cerrada'),
                  backgroundColor: Color(0xFFFF69B4),
                ),
              );

              // 🔥 redirigir al login
              context.go('/home');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Categorías',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD81B60),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                ClientCategoryItem(
                  name: 'Maquillaje',
                  icon: Icons.face,
                  color: const Color(0xFFFFB6C1),
                  onTap: () => _showComingSoon(context, 'Maquillaje'),
                ),
                ClientCategoryItem(
                  name: 'Skincare',
                  icon: Icons.spa,
                  color: const Color(0xFFDDA0DD),
                  onTap: () => _showComingSoon(context, 'Skincare'),
                ),
                ClientCategoryItem(
                  name: 'Perfumes',
                  icon: Icons.wine_bar,
                  color: const Color(0xFFFFDAB9),
                  onTap: () => _showComingSoon(context, 'Perfumes'),
                ),
                ClientCategoryItem(
                  name: 'Cabello',
                  icon: Icons.brush,
                  color: const Color(0xFFFFC0CB),
                  onTap: () => _showComingSoon(context, 'Cabello'),
                ),
                ClientCategoryItem(
                  name: 'Uñas',
                  icon: Icons.palette,
                  color: const Color(0xFFE6E6FA),
                  onTap: () => _showComingSoon(context, 'Uñas'),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              '✨ Productos Destacados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD81B60),
              ),
            ),
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15),
              childAspectRatio: 0.75,
              children: [
                ClientProductCard(
                  name: 'Labial Mate',
                  price: '\$25.99',
                  rating: '⭐ 4.8',
                  color: const Color(0xFFFF6B81),
                  onTap: () => _showComingSoon(context, 'Labial Mate'),
                ),
                ClientProductCard(
                  name: 'Serum Facial',
                  price: '\$45.50',
                  rating: '⭐ 4.9',
                  color: const Color(0xFF87CEEB),
                  onTap: () => _showComingSoon(context, 'Serum Facial'),
                ),
                ClientProductCard(
                  name: 'Base HD',
                  price: '\$38.00',
                  rating: '⭐ 4.7',
                  color: const Color(0xFFFFD700),
                  onTap: () => _showComingSoon(context, 'Base HD'),
                ),
                ClientProductCard(
                  name: 'Perfume Floral',
                  price: '\$89.99',
                  rating: '⭐ 5.0',
                  color: const Color(0xFFDDA0DD),
                  onTap: () => _showComingSoon(context, 'Perfume Floral'),
                ),
                ClientProductCard(
                  name: 'Paleta de Sombras',
                  price: '\$52.00',
                  rating: '⭐ 4.9',
                  color: const Color(0xFFE6E6FA),
                  onTap: () => _showComingSoon(context, 'Paleta de Sombras'),
                ),
                ClientProductCard(
                  name: 'Crema Hidratante',
                  price: '\$34.99',
                  rating: '⭐ 4.6',
                  color: const Color(0xFF98FB98),
                  onTap: () => _showComingSoon(context, 'Crema Hidratante'),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFFF69B4),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          String message = ['Inicio', 'Buscador', 'Favoritos', 'Perfil'][index];
          _showComingSoon(context, message);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
