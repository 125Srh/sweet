// lib/features/public/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:sweet/features/auth/register/screens/register_admin_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          // Botón Crear Admin
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterAdminScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: Color(0xFFFF69B4),
              ),
              label: const Text(
                'Crear Admin',
                style: TextStyle(color: Color(0xFFFF69B4), fontSize: 12),
              ),
            ),
          ),
          // Botón Iniciar Sesión
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.login, size: 16, color: Colors.white),
              label: const Text(
                'Iniciar Sesión',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),

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
                CategoryItem(
                  name: 'Maquillaje',
                  icon: Icons.face,
                  color: const Color(0xFFFFB6C1),
                  onTap: () => _showComingSoon(context, 'Maquillaje'),
                ),
                CategoryItem(
                  name: 'Skincare',
                  icon: Icons.spa,
                  color: const Color(0xFFDDA0DD),
                  onTap: () => _showComingSoon(context, 'Skincare'),
                ),
                CategoryItem(
                  name: 'Perfumes',
                  icon: Icons.wine_bar,
                  color: const Color(0xFFFFDAB9),
                  onTap: () => _showComingSoon(context, 'Perfumes'),
                ),
                CategoryItem(
                  name: 'Cabello',
                  icon: Icons.brush,
                  color: const Color(0xFFFFC0CB),
                  onTap: () => _showComingSoon(context, 'Cabello'),
                ),
                CategoryItem(
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
                ProductCard(
                  name: 'Labial Mate',
                  price: '\$25.99',
                  rating: '⭐ 4.8',
                  color: const Color(0xFFFF6B81),
                  onTap: () => _showComingSoon(context, 'Labial Mate'),
                ),
                ProductCard(
                  name: 'Serum Facial',
                  price: '\$45.50',
                  rating: '⭐ 4.9',
                  color: const Color(0xFF87CEEB),
                  onTap: () => _showComingSoon(context, 'Serum Facial'),
                ),
                ProductCard(
                  name: 'Base HD',
                  price: '\$38.00',
                  rating: '⭐ 4.7',
                  color: const Color(0xFFFFD700),
                  onTap: () => _showComingSoon(context, 'Base HD'),
                ),
                ProductCard(
                  name: 'Perfume Floral',
                  price: '\$89.99',
                  rating: '⭐ 5.0',
                  color: const Color(0xFFDDA0DD),
                  onTap: () => _showComingSoon(context, 'Perfume Floral'),
                ),
                ProductCard(
                  name: 'Paleta de Sombras',
                  price: '\$52.00',
                  rating: '⭐ 4.9',
                  color: const Color(0xFFE6E6FA),
                  onTap: () => _showComingSoon(context, 'Paleta de Sombras'),
                ),
                ProductCard(
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
