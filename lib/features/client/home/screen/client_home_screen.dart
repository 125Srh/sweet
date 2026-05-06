import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widget/client_category_item.dart';
import '../widget/client_product_card.dart';
import 'package:provider/provider.dart';
import '../provider/client_provider.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
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
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ClientProvider>(context, listen: false).init(),
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
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás segura que deseas salir de Sweet?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Salir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmar == true) {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚪 Sesión cerrada'),
                    backgroundColor: Color(0xFFFF69B4),
                  ),
                );
                context.go('/login');
              }
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟣 CATEGORÍAS
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
            child: Consumer<ClientProvider>(
              builder: (context, provider, child) {
                if (provider.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];

                    final colors = [
                      Color(0xFFFFB6C1),
                      Color(0xFFDDA0DD),
                      Color(0xFFFFDAB9),
                      Color(0xFFFFC0CB),
                      Color(0xFFE6E6FA),
                    ];

                    final icons = [
                      Icons.face,
                      Icons.spa,
                      Icons.wine_bar,
                      Icons.brush,
                      Icons.palette,
                    ];

                    return ClientCategoryItem(
                      name: cat['nombre'],
                      icon: icons[index % icons.length],
                      color: colors[index % colors.length],
                      onTap: () {
                        context.read<ClientProvider>().filterByCategory(
                          cat['id'],
                        );
                      },
                    );
                  },
                );
              },
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

          // 🔥 PRODUCTOS
          Expanded(
            child: Consumer<ClientProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          'No hay productos en esta categoría',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            provider.resetProducts();
                          },
                          child: const Text(
                            'ver todos',
                            style: TextStyle(color: Color(0xFFD81B60)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: provider.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = provider.products[index];

                    return ClientProductCard(
                      name: product['nombre'],
                      price: '\$${product['precio']}',
                      rating: '⭐ 5.0',
                      imageUrl: product['imagen_url'],
                      color: [
                        Color(0xFFFF6B81),
                        Color(0xFF87CEEB),
                        Color(0xFFFFD700),
                        Color(0xFFDDA0DD),
                        Color(0xFF98FB98),
                      ][index % 5],
                      onTap: () {},
                    );
                  },
                );
              },
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
