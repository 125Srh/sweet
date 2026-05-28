import 'package:flutter/material.dart';
import '../service/client_service.dart';
import 'package:sweet/main.dart'; // 🌟 Importamos tu messengerKey global

class ClientOrdersScreen extends StatefulWidget {
  const ClientOrdersScreen({super.key});

  @override
  State<ClientOrdersScreen> createState() => _ClientOrdersScreenState();
}

class _ClientOrdersScreenState extends State<ClientOrdersScreen> {
  final service = ClientService();
  List<Map<String, dynamic>> pedidos = [];

  // Mapa local para saber qué pedido se está procesando actualmente
  final Map<String, bool> _cargandoPedidos = {};

  // Color base del proyecto (respetando tu rosa original)
  final Color rosaPrincipal = const Color(0xFFFF69B4);
  final Color rosaPastelSuave = const Color(
    0xFFFFF0F5,
  ); // LavenderBlush muy tierno

  @override
  void initState() {
    super.initState();
    debugPrint(
      '📦 [ORDERS DIAGNÓSTICO] initState: Cargando pedidos por primera vez...',
    );
    cargarPedidos();
  }

  @override
  void dispose() {
    debugPrint(
      '📦 [ORDERS DIAGNÓSTICO] dispose: Cerrando pantalla de pedidos y destruyendo su estado.',
    );
    super.dispose();
  }

  Future<void> cargarPedidos() async {
    debugPrint(
      '📦 [ORDERS DIAGNÓSTICO] Solicitando lista de pedidos al servicio...',
    );
    try {
      final res = await service.getMisPedidos();

      debugPrint(
        '📦 [ORDERS DIAGNÓSTICO] Respuesta del servicio recibida. ¿El widget sigue montado?: $mounted',
      );
      if (!mounted) {
        debugPrint(
          '📦 [ORDERS DIAGNÓSTICO] Abortando setState en cargarPedidos: El usuario ya se salió de la pantalla.',
        );
        return;
      }

      setState(() {
        pedidos = res;
      });
      debugPrint(
        '📦 [ORDERS DIAGNÓSTICO] Lista de pedidos actualizada en el estado con éxito. Total: ${pedidos.length}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [ORDERS ERROR] Falló cargarPedidos: $e');
      debugPrint('📋 STACKTRACE EN cargarPedidos:\n$stackTrace');
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

  Color estadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.grey.shade500;
      case 'en_preparacion':
        return Colors.amber.shade700;
      case 'listo':
        return Colors.lightBlue.shade400;
      case 'enviado':
        return Colors.purple.shade300;
      case 'recibido':
        return Colors.pink.shade300;
      default:
        return Colors.black;
    }
  }

  IconData estadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.favorite_border_rounded;
      case 'en_preparacion':
        return Icons.auto_awesome_rounded;
      case 'listo':
        return Icons.card_giftcard_rounded;
      case 'enviado':
        return Icons.local_shipping_rounded;
      case 'recibido':
        return Icons.celebration_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> marcarRecibido(String pedidoId) async {
    debugPrint(
      '📦 [ORDERS DIAGNÓSTICO] Botón "Lo recibí" presionado para el ID: $pedidoId',
    );

    if (!mounted) return;
    setState(() {
      _cargandoPedidos[pedidoId] = true;
    });

    try {
      debugPrint(
        '📦 [ORDERS DIAGNÓSTICO] Enviando petición asíncrona a Supabase para marcar como recibido...',
      );
      // 1️⃣ Cambiar el estado en la base de datos
      await service.marcarComoRecibido(pedidoId);

      if (!mounted) return;

      debugPrint(
        '📦 [ORDERS DIAGNÓSTICO] Petición completada. Descargando lista fresca de la BD...',
      );
      // 2️⃣ Traer directamente los datos actualizados desde el servicio
      final nuevosPedidos = await service.getMisPedidos();

      if (!mounted) return;

      // 3️⃣ UNIFICAR EL ESTADO: Seteamos la nueva lista de pedidos y apagamos el loading AL MISMO TIEMPO
      setState(() {
        pedidos = nuevosPedidos;
        _cargandoPedidos[pedidoId] = false;
      });

      debugPrint(
        '📦 [ORDERS DIAGNÓSTICO] Interfaz actualizada. Mostrando SnackBar...',
      );
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('🎉 ¡Pedido marcado como recibido!'),
          backgroundColor: Color(0xFFFF69B4),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [ORDERS ERROR] Falló marcarRecibido: $e');
      debugPrint('📋 STACKTRACE EN marcarRecibido:\n$stackTrace');

      // Si el proceso falla, apagamos el loading de forma segura para no romper la UI
      if (mounted) {
        setState(() {
          _cargandoPedidos[pedidoId] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Mis pedidos",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: rosaPrincipal,
        centerTitle: true,
        elevation: 0,
      ),
      body: pedidos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars_rounded,
                    size: 70,
                    color: rosaPrincipal.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Aún no tienes pedidos registrados",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: pedidos.length,
              itemBuilder: (_, i) {
                final pedido = pedidos[i];
                final id = pedido['id']?.toString() ?? '';
                final estado = pedido['estado'] ?? 'pendiente';
                final estaCargando = _cargandoPedidos[id] ?? false;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: rosaPastelSuave, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: rosaPrincipal.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bubble_chart_rounded,
                                  color: rosaPrincipal.withOpacity(0.5),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Mi Pedido",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor(estado).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    estadoIcon(estado),
                                    color: estadoColor(estado),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    estadoLabel(estado),
                                    style: TextStyle(
                                      color: estadoColor(estado),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total de tu orden",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "Bs. ${pedido['total']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: rosaPrincipal,
                              ),
                            ),
                          ],
                        ),
                        if (estaCargando || estado == 'enviado') ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: estaCargando
                                ? Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: rosaPrincipal,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: rosaPrincipal,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () => marcarRecibido(id),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Lo recibí",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
