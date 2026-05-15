import 'package:flutter/material.dart';
import '../service/admin_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final service = AdminService();
  List<Map<String, dynamic>> pedidos = [];

  final primaryPink = const Color(0xFFE91E63);
  final softPink = const Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    final res = await service.getPedidos();
    setState(() {
      pedidos = res;
    });
  }

  Color getColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.grey;
      case 'proceso':
        return Colors.orange;
      case 'finalizado':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  IconData getIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.access_time;
      case 'proceso':
        return Icons.sync;
      case 'finalizado':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de pedidos'),
        backgroundColor: primaryPink,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          final pedido = pedidos[index];
          final estado = pedido['estado'];

          final cliente = pedido['usuario'] != null
              ? "${pedido['usuario']['nombre']} ${pedido['usuario']['apellido']}"
              : "Cliente desconocido";

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, softPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 Cliente
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryPink.withOpacity(0.2),
                        child: const Icon(Icons.person, color: Colors.pink),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cliente,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 💰 Total
                  Text(
                    "Total: Bs. ${pedido['total']}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔄 Estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getColor(estado).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getIcon(estado),
                          color: getColor(estado),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          estado.toUpperCase(),
                          style: TextStyle(
                            color: getColor(estado),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⚙️ Acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 👁️ Ver pedido
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          mostrarDetallePedido(pedido['id']);
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text("Ver pedido"),
                      ),

                      // 🔄 Cambiar estado
                      DropdownButton<String>(
                        value: estado,
                        underline: Container(),
                        onChanged: (value) async {
                          await service.actualizarEstadoPedido(
                            pedido['id'],
                            value!,
                          );
                          cargarPedidos();
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'pendiente',
                            child: Text('Pedido hecho'),
                          ),
                          DropdownMenuItem(
                            value: 'proceso',
                            child: Text('En proceso'),
                          ),
                          DropdownMenuItem(
                            value: 'finalizado',
                            child: Text('Finalizado'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🛍️ Modal bonito
  void mostrarDetallePedido(String pedidoId) async {
    final detalles = await service.getDetallePedido(pedidoId);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, softPink],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🛍️ Detalle del pedido",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: detalles.length,
                  itemBuilder: (_, i) {
                    final item = detalles[i];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.pink),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              item['producto']['nombre'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("x${item['cantidad']}"),
                              Text(
                                "Bs. ${item['subtotal']}",
                                style: const TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
