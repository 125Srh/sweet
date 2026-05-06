import 'package:flutter/material.dart';
import 'package:sweet/features/client/home/widget/swipeToCarButton.dart';

class ClientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ClientDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product['imagen_url'];
    final name = product['nombre'];
    final price = product['precio'];
    final description = product['descripcion'] ?? 'Sin descripción';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // 💖 fondo rosado suave
      body: Column(
        children: [
          // 🔥 IMAGEN + GRADIENTE + BACK
          Stack(
            children: [
              SizedBox(
                height: 300,
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
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFF48FB1).withOpacity(0.3),
                      const Color(0xFFF48FB1).withOpacity(0.6),
                    ],
                    stops: const [0.6, 0.8, 1.0], // 👈 clave
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
            ],
          ),

          // 🔥 CONTENIDO
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: const [
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

                    // 📝 DESCRIPCIÓN TITLE
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📄 DESCRIPCIÓN TEXTO
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    // 💖 BOTÓN SWIPE BONITO
                    // 💖 BOTÓN SWIPE
                    SizedBox(
                      width: double.infinity,
                      child: SwipeToCartButton(
                        onConfirmed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '🛒 Producto agregado al carrito 💖',
                              ),
                              backgroundColor: Color(0xFFD81B60),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
