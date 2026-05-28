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
      case 'en_preparacion':
        return Colors.orange;
      case 'listo':
        return Colors.blue;
      case 'enviado':
        return Colors.purple;
      case 'recibido':
        return Colors.pink; // 🌸 Rosa Sweet para el final exitoso
      default:
        return Colors.black;
    }
  }

  IconData getIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.access_time;
      case 'en_preparacion':
        return Icons.restaurant;
      case 'listo':
        return Icons.check;
      case 'enviado':
        return Icons.local_shipping;
      case 'recibido':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String estadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_preparacion':
        return 'En preparación';
      case 'listo':
        return 'Listo';
      case 'enviado':
        return 'Enviado';
      case 'recibido':
        return 'Recibido';
      default:
        return estado;
    }
  }

  List<String> estadosAdmin = [
    'pendiente',
    'en_preparacion',
    'listo',
    'enviado',
    'recibido',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de pedidos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPink,
        centerTitle: true,
      ),
      body: pedidos.isEmpty
          ? Center(
              child: Text(
                "No hay pedidos registrados",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final estado = pedido['estado'];

                // 🌟 DETECTAMOS SI EL PEDIDO YA FUE RECIBIDO
                final esPedidoRecibido = estado == 'recibido';

                final cliente = pedido['usuario'] != null
                    ? "${pedido['usuario']['nombre']} ${pedido['usuario']['apellido']}"
                    : "Cliente desconocido";

                // Extraemos números del UUID para identificar el pedido de forma bonita
                final soloNumeros = pedido['id'].toString().replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                final numeroPedidoFinal = soloNumeros.length >= 5
                    ? soloNumeros.substring(0, 5)
                    : "Orden";

                return Container(
                  key: ValueKey(pedido['id']),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, softPink.withOpacity(0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.05),
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
                        // Encabezado con número de orden e indicador de estado
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: primaryPink.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    color: primaryPink,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  cliente,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "N° $numeroPedidoFinal",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Total: Bs. ${pedido['total']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Etiqueta de Estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getColor(estado).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getIcon(estado),
                                color: getColor(estado),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                estadoLabel(estado),
                                style: TextStyle(
                                  color: getColor(estado),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Acciones de la orden
                        Row(
                          children: [
                            // Botón "Ver detalles"
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryPink,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () =>
                                      mostrarDetallePedido(pedido['id']),
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text(
                                    "Ver",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Selector de estado o Vista de completado si ya fue recibido
                            Flexible(
                              flex: 1,
                              child: esPedidoRecibido
                                  ? Container(
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.pink.shade50,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.pink.shade100,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.stars_rounded,
                                            color: Colors.pink,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Completado",
                                            style: TextStyle(
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : DropdownButtonFormField<String>(
                                      key: ValueKey('dropdown_${pedido['id']}'),
                                      value: estadosAdmin.contains(estado)
                                          ? estado
                                          : 'pendiente',
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.pink.shade100,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide(
                                            color: primaryPink,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) async {
                                        if (value == null || value == estado)
                                          return;
                                        await service.actualizarEstadoPedido(
                                          pedido['id'],
                                          value,
                                        );
                                        cargarPedidos();
                                      },
                                      items: estadosAdmin.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          // 🌟 Impedimos seleccionar estados incoherentes manualmente si se desea
                                          child: Text(
                                            estadoLabel(e),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
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

  // Modal de Detalle
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
              colors: [Colors.white, softPink.withOpacity(0.5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🛍️ Detalle del pedido",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryPink,
                ),
              ),
              const SizedBox(height: 12),
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
                            color: Colors.pink.withOpacity(0.04),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag, color: primaryPink),
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
                                style: TextStyle(
                                  color: primaryPink,
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
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
