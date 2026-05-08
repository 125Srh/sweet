import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/payment_method_widget.dart';
import '../../pedido/screens/pedido_confirmado_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(),
      child: const _CheckoutContent(),
    );
  }
}

class _CheckoutContent extends StatefulWidget {
  const _CheckoutContent();

  @override
  State<_CheckoutContent> createState() => _CheckoutContentState();
}

class _CheckoutContentState extends State<_CheckoutContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener datos pasados desde AddressScreen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map) {
      final provider = context.read<CheckoutProvider>();
      provider.inicializarCarrito(
        subtotal: args['subtotal'] ?? 0.0,
        totalItems: args['totalItems'] ?? 0,
        items: args['items'] ?? [],
      );
      if (args['direccion'] != null) {
        provider.setDireccion(args['direccion']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Confirmar pedido',
          style: TextStyle(
            color: Color(0xFFD81B60),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFD81B60)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF69B4)),
                  SizedBox(height: 16),
                  Text('Procesando pedido...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de productos
                  _buildResumenProductos(provider),
                  const SizedBox(height: 20),

                  // Dirección de entrega
                  _buildDireccionEntrega(provider),
                  const SizedBox(height: 20),

                  // Selección de envío
                  _buildEnvioWidget(provider),
                  const SizedBox(height: 20),

                  // Método de pago
                  PaymentMethodWidget(
                    selectedMethod: provider.metodoPago,
                    onChanged: (method) => provider.setMetodoPago(method),
                  ),
                  const SizedBox(height: 20),

                  // Totales
                  _buildTotales(provider),
                  const SizedBox(height: 30),

                  // Botón confirmar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await provider.procesarPago();
                        if (success && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PedidoConfirmadoScreen(),
                              settings: RouteSettings(
                                arguments: {
                                  'total': provider.total,
                                  'metodoPago': provider.metodoPago,
                                  'direccion': provider.direccion,
                                  'items': provider.items,
                                },
                              ),
                            ),
                          );
                        } else if (context.mounted && provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${provider.error}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF69B4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar pedido',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildResumenProductos(CheckoutProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de productos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...provider.items.map((item) {
            final producto = item['producto'] as Map<String, dynamic>? ?? {};
            final cantidad = item['cantidad'] as int? ?? 1;
            final precio = (item['precio_unitario'] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF69B4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.spa, color: Color(0xFFFF69B4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto['nombre']?.toString() ?? 'Producto',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('Cantidad: $cantidad', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    'Bs. ${(precio * cantidad).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD81B60)),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Bs. ${provider.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total items', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${provider.totalItems} productos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDireccionEntrega(CheckoutProvider provider) {
    final dir = provider.direccion;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFFFF69B4), size: 20),
              SizedBox(width: 8),
              Text('Dirección de entrega', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (dir.isNotEmpty) ...[
            Text(dir['direccion'] ?? '', style: const TextStyle(fontSize: 14)),
            if (dir['referencias'] != null && dir['referencias'].isNotEmpty)
              Text(dir['referencias'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Celular: ${dir['celular'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ] else ...[
            const Text('No se ha seleccionado dirección', style: TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _buildEnvioWidget(CheckoutProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Método de envío', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...provider.opcionesEnvio.map((envio) => RadioListTile<double>(
                title: Text(envio['nombre']),
                subtitle: Text(envio['dias']),
                secondary: Text('Bs. ${envio['costo'].toStringAsFixed(2)}'),
                value: envio['costo'],
                groupValue: provider.costoEnvio,
                onChanged: (value) => provider.setCostoEnvio(value!),
                activeColor: const Color(0xFFFF69B4),
                contentPadding: EdgeInsets.zero,
              )),
        ],
      ),
    );
  }

  Widget _buildTotales(CheckoutProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E9)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 14)),
              Text('Bs. ${provider.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Envío', style: TextStyle(fontSize: 14)),
              Text(
                provider.costoEnvio == 0 ? 'Gratis' : 'Bs. ${provider.costoEnvio.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
              Text('Bs. ${provider.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
            ],
          ),
        ],
      ),
    );
  }
}