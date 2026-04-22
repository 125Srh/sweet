import 'package:flutter/material.dart';
import 'package:sweet/features/auth/register/screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, Bella!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Descubre nuestras ofertas exclusivas',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.spa, color: Colors.white, size: 50),
              ],
            ),
          ),
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
                _buildCategory(
                  'Maquillaje',
                  Icons.face,
                  const Color(0xFFFFB6C1),
                  context,
                ),
                _buildCategory(
                  'Skincare',
                  Icons.spa,
                  const Color(0xFFDDA0DD),
                  context,
                ),
                _buildCategory(
                  'Perfumes',
                  Icons.wine_bar,
                  const Color(0xFFFFDAB9),
                  context,
                ),
                _buildCategory(
                  'Cabello',
                  Icons.brush,
                  const Color(0xFFFFC0CB),
                  context,
                ),
                _buildCategory(
                  'Uñas',
                  Icons.palette,
                  const Color(0xFFE6E6FA),
                  context,
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
                _buildProductCard(
                  'Labial Mate',
                  '\$25.99',
                  '⭐ 4.8',
                  const Color(0xFFFF6B81),
                  context,
                ),
                _buildProductCard(
                  'Serum Facial',
                  '\$45.50',
                  '⭐ 4.9',
                  const Color(0xFF87CEEB),
                  context,
                ),
                _buildProductCard(
                  'Base HD',
                  '\$38.00',
                  '⭐ 4.7',
                  const Color(0xFFFFD700),
                  context,
                ),
                _buildProductCard(
                  'Perfume Floral',
                  '\$89.99',
                  '⭐ 5.0',
                  const Color(0xFFDDA0DD),
                  context,
                ),
                _buildProductCard(
                  'Paleta de Sombras',
                  '\$52.00',
                  '⭐ 4.9',
                  const Color(0xFFE6E6FA),
                  context,
                ),
                _buildProductCard(
                  'Crema Hidratante',
                  '\$34.99',
                  '⭐ 4.6',
                  const Color(0xFF98FB98),
                  context,
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

  Widget _buildCategory(
    String name,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showComingSoon(context, name),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFD81B60), size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    String name,
    String price,
    String rating,
    Color color,
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showComingSoon(context, name),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Center(child: Icon(Icons.spa, size: 50, color: color)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(rating, style: const TextStyle(fontSize: 12)),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFFD81B60),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 $feature - ¡Próximamente!'),
        backgroundColor: const Color(0xFFFF69B4),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
