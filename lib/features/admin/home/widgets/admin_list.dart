import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweet/features/admin/home/providers/admin_provider.dart';
import '../widgets/admin_form.dart';

class AdminList extends StatelessWidget {
  const AdminList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminsProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.filteredProductos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('No hay productos registrados',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.filteredProductos.length,
      itemBuilder: (_, i) {
        final producto = provider.filteredProductos[i];
        final stock = (producto['stock'] as int?) ?? 0;
        final precio = (producto['precio'] as num?)?.toDouble() ?? 0.0;
        final imagenUrl = producto['imagen_url']?.toString();
        final stockBajo = stock > 0 && stock <= 3;
        final agotado = stock <= 0;
        final activo = producto['activo'] as bool? ?? true;

        return Opacity(
          opacity: activo ? 1.0 : 0.65,
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF69B4).withOpacity(0.1),
                      ),
                      child: imagenUrl != null && imagenUrl.isNotEmpty
                          ? Image.network(imagenUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.inventory_2, color: Color(0xFFFF69B4), size: 30))
                          : const Icon(Icons.inventory_2, color: Color(0xFFFF69B4), size: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(producto['nombre'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(producto['descripcion'] ?? '',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Bs. ${precio.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold,
                                    color: Color(0xFFD81B60), fontSize: 14)),
                            const SizedBox(width: 14),
                            if (!activo)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[400]!)),
                                child: Text('BLOQUEADO',
                                    style: TextStyle(color: Colors.grey[800], fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              )
                            else if (agotado)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!)),
                                child: Text('AGOTADO',
                                    style: TextStyle(color: Colors.red[700], fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              )
                            else if (stockBajo)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!)),
                                child: Text('Stock: $stock',
                                    style: TextStyle(color: Colors.orange[700], fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!)),
                                child: Text('Stock: $stock',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          activo ? Icons.lock_open_outlined : Icons.lock_outlined,
                          color: activo ? Colors.green : Colors.orange,
                          size: 18,
                        ),
                        onPressed: () async {
                          final result = await provider.toggleEstadoActivo(
                            producto['id'].toString(),
                            activo,
                          );
                          if (result == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(activo
                                      ? 'Producto "${producto['nombre']}" bloqueado temporalmente.'
                                      : 'Producto "${producto['nombre']}" desbloqueado y activo.'),
                                  backgroundColor: activo ? Colors.orange : Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $result'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AdminForm(producto: producto))),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('¿Eliminar producto?'),
                              content: Text('¿Estás segura de eliminar "${producto['nombre']}" permanentemente?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Cerrar diálogo de confirmación
                                    Navigator.pop(context);

                                    // Mostrar loading dialog
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
                                        ),
                                      ),
                                    );

                                    // Verificar si tiene pedidos pendientes
                                    final tienePendientes = await provider.verificarPedidosPendientes(
                                      producto['id'].toString(),
                                    );

                                    // Cerrar loading dialog
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }

                                    if (tienePendientes) {
                                      // Mostrar diálogo de error
                                      if (context.mounted) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            title: Row(
                                              children: const [
                                                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                                SizedBox(width: 8),
                                                Text('No se puede eliminar'),
                                              ],
                                            ),
                                            content: Text(
                                              'El producto "${producto['nombre']}" no se puede eliminar porque tiene pedidos pendientes.\n\n'
                                              'Si deseas deshabilitarlo temporalmente, puedes usar la opción de "Bloquear" (icono del candado).',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Entendido'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    } else {
                                      // Eliminar de forma segura
                                      await provider.eliminarProducto(producto['id'].toString());
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Producto "${producto['nombre']}" eliminado definitivamente.'),
                                            backgroundColor: Colors.red[700],
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}