import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/client_provider.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();

    final results = provider.products.where((p) {
      final nombre = (p['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar productos'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔍 INPUT
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() => query = value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 🧁 RESULTADOS
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final product = results[index];
                return ListTile(
                  onTap: () {
                    final id = product['id']?.toString() ?? '';
                    context.push('/client/producto/$id', extra: product);
                  },
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        product['imagen_url'] != null &&
                            product['imagen_url'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['imagen_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.spa, color: Colors.pink),
                            ),
                          )
                        : const Icon(Icons.spa, color: Colors.pink),
                  ),
                  title: Text(product['nombre'] ?? ''),
                  subtitle: Text('Bs. ${product['precio']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
