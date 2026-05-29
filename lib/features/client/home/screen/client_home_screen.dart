// lib/features/client/home/screen/client_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sweet/features/client/home/screen/client_detail_screen.dart';
import 'package:sweet/main.dart';
import '../widget/client_category_item.dart';
import 'package:provider/provider.dart';
import '../provider/client_provider.dart';
import 'package:sweet/features/client/cart/provider/cart_provider.dart';
import 'package:sweet/features/client/cart/screen/cart_screen.dart';
import 'package:sweet/features/client/cart/widget/add_to_cart_button.dart';
import 'package:sweet/features/client/favorites/screen/favorites_screen.dart';
import 'package:sweet/features/client/home/widget/search_screen.dart';
import 'package:sweet/features/client/home/screen/client_orders_screen.dart';
import 'package:sweet/features/client/home/widget/notification_bell.dart'; // ✅ IMPORT CORREGIDO

import 'package:sweet/main.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentNav = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ClientProvider>().init();
      context.read<CartProvider>().cargar();
    });
  }

  void _showComingSoon(String feature) {
    // 🌟 1. Limpiamos cualquier SnackBar activo o colgado para detener sus animaciones
    messengerKey.currentState?.clearSnackBars();

    // 🌟 2. Mostramos el nuevo usando la clave global sin tocar el 'context' de la pantalla
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('🚧 $feature - ¡Próximamente!'),
        backgroundColor: const Color(0xFFFF69B4),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<Map<String, dynamic>?> _obtenerDatosUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await Supabase.instance.client
          .from('usuario')
          .select('nombre, apellido, email, rol')
          .eq('id', user.id)
          .maybeSingle();
      if (data != null) {
        return {
          'nombre': '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim(),
          'email': data['email'] ?? user.email ?? '',
          'rol': data['rol'] ?? 'Cliente',
        };
      }
    } catch (e) {
      debugPrint('Error al obtener datos de usuario: $e');
    }
    return {'nombre': 'Usuario', 'email': user.email ?? '', 'rol': 'Cliente'};
  }

  void _mostrarPerfilDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _obtenerDatosUsuario(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF69B4)),
                  ),
                );
              }
              final userData = snapshot.data;
              final nombre = userData?['nombre'] ?? 'Usuario';
              final email = userData?['email'] ?? 'No disponible';
              final rol = userData?['rol'] ?? 'Cliente';

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF69B4), Color(0xFFD81B60)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 44,
                              color: Color(0xFFD81B60),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nombre.isNotEmpty ? nombre : 'Usuario',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              rol.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF69B4).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Color(0xFFFF69B4),
                              ),
                            ),
                            title: const Text(
                              'Usuario',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              nombre.isNotEmpty ? nombre : 'Usuario',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF69B4).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFFFF69B4),
                              ),
                            ),
                            title: const Text(
                              'Gmail',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: Text(
                              email,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD81B60),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Cerrar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _irAlCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    ).then((_) => setState(() => _currentNav = 0));
  }

  void _irAFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    ).then((_) => setState(() => _currentNav = 0));
  }

  Future<void> _refresh() async {
    await context.read<ClientProvider>().init();
    await context.read<CartProvider>().cargar();
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
          // 🔔 NOTIFICACIONES - Componente bonito
          const NotificationBell(),
          // PopupMenu existente
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: Color(0xFFFF69B4)),
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) async {
              debugPrint('🚀 [DIAGNÓSTICO] PopupMenu seleccionado: $value');
              debugPrint('📌 [DIAGNÓSTICO] ¿El Home está montado?: $mounted');

              try {
                messengerKey.currentState?.clearSnackBars();

                switch (value) {
                  case 'pedidos':
                    debugPrint(
                      '🚀 [DIAGNÓSTICO] Intentando abrir ClientOrdersScreen...',
                    );
                    if (!mounted) {
                      debugPrint(
                        '⚠️ [ALERTA] Intentaste abrir pedidos en un widget desactivado!',
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientOrdersScreen(),
                      ),
                    );
                    break;

                  case 'favoritos':
                    if (!mounted) return;
                    _irAFavoritos();
                    break;

                  case 'logout':
                    debugPrint(
                      '🚀 [DIAGNÓSTICO] Abriendo diálogo de cerrar sesión...',
                    );
                    if (!mounted) return;

                    final confirmar = await showDialog<bool>(
                      context: context,
                      useRootNavigator: true,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                      debugPrint(
                        '🚀 [DIAGNÓSTICO] Confirmación aceptada. Ejecutando SignOut...',
                      );

                      final messenger = messengerKey.currentState;

                      if (mounted) {
                        context.go('/login');
                      }

                      Future.delayed(const Duration(milliseconds: 100), () async {
                        try {
                          await Supabase.instance.client.auth.signOut();
                          messenger?.clearSnackBars();
                          messenger?.showSnackBar(
                            const SnackBar(
                              content: Text('Sesión cerrada correctamente'),
                              backgroundColor: Color(0xFFFF69B4),
                            ),
                          );
                        } catch (signOutError) {
                          debugPrint(
                            '❌ Error real interno en Supabase SignOut: $signOutError',
                          );
                        }
                      });
                    }
                    break;
                }
              } catch (e, stackTrace) {
                debugPrint('❌ [ERROR DETECTADO EN POPUPMENU]: $e');
                debugPrint('📋 STACKTRACE DEL ERROR:\n$stackTrace');
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'pedidos',
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 20,
                      color: Color(0xFFD81B60),
                    ),
                    SizedBox(width: 10),
                    Text('Mis pedidos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favoritos',
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Color(0xFFD81B60),
                    ),
                    SizedBox(width: 10),
                    Text('Favoritos'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── BANNER PROMOCIONAL (SIN botón "Ver ofertas") ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Nueva Colección!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Descubre nuestros productos exclusivos',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── CATEGORÍAS ────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                final colors = [
                  const Color(0xFFFFB6C1),
                  const Color(0xFFDDA0DD),
                  const Color(0xFFFFDAB9),
                  const Color(0xFFFFC0CB),
                  const Color(0xFFE6E6FA),
                ];
                final icons = [
                  Icons.face,
                  Icons.spa,
                  Icons.wine_bar,
                  Icons.brush,
                  Icons.palette,
                ];
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];
                    return ClientCategoryItem(
                      name: cat['nombre'] ?? '',
                      icon: icons[index % icons.length],
                      color: colors[index % colors.length],
                      imageUrl: cat['imagen_url'],
                      onTap: () => context
                          .read<ClientProvider>()
                          .filterByCategory(cat['id']),
                    );
                  },
                );
              },
            ),
          ),

          // ── PRODUCTOS ──────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFFFF69B4),
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Text(
                      'Productos Destacados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
                      ),
                    ),
                  ),
                  Consumer<ClientProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF69B4),
                            ),
                          ),
                        );
                      }
                      if (provider.products.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.inbox,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No hay productos en esta categoría',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () => context
                                      .read<ClientProvider>()
                                      .resetProducts(),
                                  child: const Text(
                                    'ver todos',
                                    style: TextStyle(color: Color(0xFFD81B60)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final colors = [
                        const Color(0xFFFF6B81),
                        const Color(0xFF87CEEB),
                        const Color(0xFFFFD700),
                        const Color(0xFFDDA0DD),
                        const Color(0xFF98FB98),
                      ];
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                        itemCount: provider.products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.62,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          final prodId = product['id']?.toString() ?? '';
                          final nombre = product['nombre'] ?? '';
                          final precio =
                              (product['precio'] as num?)?.toDouble() ?? 0.0;
                          final stock = (product['stock'] as int?) ?? 0;
                          final imagen = product['imagen_url'];
                          final color = colors[index % colors.length];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ClientDetailScreen(
                                          product: product,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        color: color.withOpacity(0.2),
                                        child:
                                            imagen != null &&
                                                imagen.toString().isNotEmpty
                                            ? Image.network(
                                                imagen,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Center(
                                                      child: Icon(
                                                        Icons.spa,
                                                        size: 45,
                                                        color: color,
                                                      ),
                                                    ),
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.spa,
                                                  size: 45,
                                                  color: color,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    8,
                                    10,
                                    10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        '5.0',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(
                                        'Bs. ${precio.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFFD81B60),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
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
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNav,
        selectedItemColor: const Color(0xFFFF69B4),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _currentNav = i);
          switch (i) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ).then((_) => setState(() => _currentNav = 0));
              break;
            case 2:
              _irAlCarrito();
              break;
            case 3:
              _irAFavoritos();
              break;
            case 4:
              _mostrarPerfilDialog(context);
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            label: 'Carrito',
            icon: Consumer<CartProvider>(
              builder: (context, cart, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD81B60),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            cart.totalItems > 99 ? '99+' : '${cart.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
