import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/pay_provider.dart';
import '../../cart/provider/cart_provider.dart';

class PayScreen extends StatefulWidget {
  final String direccionCompleta;
  final String referencia;
  final String celular;

  const PayScreen({
    super.key,
    required this.direccionCompleta,
    required this.referencia,
    required this.celular,
  });

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final _formKey = GlobalKey<FormState>();
  String _metodoPago = 'tarjeta_simulada';
  String _tarjetaNumero = '';
  final double _costoEnvio = 15.00;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayProvider>().clearMessages();
    });
  }

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final payProvider = context.read<PayProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío'), backgroundColor: Colors.red),
      );
      return;
    }

    final productos = cart.items.map((item) {
      final producto = item['producto'] as Map<String, dynamic>;
      final cantidad = item['cantidad'] as int;
      final precio = (item['precio_unitario'] as num).toDouble();
      
      return {
        'producto_id': producto['id'].toString(),
        'nombre': producto['nombre'].toString(),
        'imagen_url': producto['imagen_url']?.toString() ?? '',
        'precio_unitario': precio,
        'cantidad': cantidad,
        'subtotal': cantidad * precio,
      };
    }).toList();

    final exito = await payProvider.procesarPago(
      subtotal: cart.subtotal,
      envio: _costoEnvio,
      total: cart.subtotal + _costoEnvio,
      direccion: widget.direccionCompleta,
      referencia: widget.referencia,
      celular: widget.celular,
      metodoPago: _metodoPago,
      tarjetaNumero: _tarjetaNumero,
      productos: productos,
    );

    if (!mounted) return;

    if (exito) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text('¡Pago Exitoso!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(payProvider.successMessage ?? 'Pedido realizado correctamente'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Volver al inicio', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(payProvider.errorMessage ?? 'Error al procesar el pago'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final payProvider = context.watch<PayProvider>();
    final total = cart.subtotal + _costoEnvio;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pagar Pedido', style: TextStyle(color: Color(0xFFD81B60), fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFD81B60)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
          : cart.items.isEmpty
              ? _carritoVacio()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _resumenPedido(cart, total),
                      const SizedBox(height: 20),
                      _formularioPago(),
                      const SizedBox(height: 20),
                      _botonPagar(payProvider),
                    ],
                  ),
                ),
    );
  }

  Widget _resumenPedido(CartProvider cart, double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [Icon(Icons.receipt_long, color: Color(0xFFFF69B4)), SizedBox(width: 8), Text('Resumen del Pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD81B60)))]),
          ),
          const Divider(height: 0, color: Color(0xFFFFE4E9)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: cart.items.length,
            itemBuilder: (_, i) {
              final item = cart.items[i];
              final producto = item['producto'] as Map<String, dynamic>? ?? {};
              final nombre = producto['nombre']?.toString() ?? 'Producto';
              final cantidad = (item['cantidad'] as int?) ?? 1;
              final precio = (item['precio_unitario'] as num?)?.toDouble() ?? 0;
              final subtotal = cantidad * precio;
              final imagenUrl = producto['imagen_url']?.toString();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: const Color(0xFFFF69B4).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: imagenUrl != null && imagenUrl.isNotEmpty ? Image.network(imagenUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.spa, color: Color(0xFFFF69B4))) : const Icon(Icons.spa, color: Color(0xFFFF69B4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nombre, style: const TextStyle(fontWeight: FontWeight.w500)), Text('Bs. $precio c/u', style: const TextStyle(fontSize: 12, color: Colors.grey))])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('x$cantidad', style: const TextStyle(fontSize: 13, color: Colors.grey)), const SizedBox(height: 4), Text('Bs. ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD81B60)))]),
                ]),
              );
            },
          ),
          const Divider(height: 16, color: Color(0xFFFFE4E9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _filaTotal('Subtotal', 'Bs. ${cart.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _filaTotal('Envío', 'Bs. $_costoEnvio'),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFFFE4E9)),
              const SizedBox(height: 12),
              _filaTotal('Total', 'Bs. ${total.toStringAsFixed(2)}', esTotal: true),
            ]),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.location_on, size: 16, color: Color(0xFFFF69B4)), SizedBox(width: 8), Text('Dirección de entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
              const SizedBox(height: 8),
              Text(widget.direccionCompleta, style: const TextStyle(fontSize: 12)),
              if (widget.referencia.isNotEmpty) ...[const SizedBox(height: 4), Text('Ref: ${widget.referencia}', style: const TextStyle(fontSize: 12, color: Colors.grey))],
              const SizedBox(height: 4),
              Text('Celular: ${widget.celular}', style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _filaTotal(String label, String valor, {bool esTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: esTotal ? 16 : 14, fontWeight: esTotal ? FontWeight.bold : FontWeight.normal, color: esTotal ? const Color(0xFFD81B60) : Colors.black54)),
      Text(valor, style: TextStyle(fontSize: esTotal ? 18 : 14, fontWeight: esTotal ? FontWeight.bold : FontWeight.w500, color: esTotal ? const Color(0xFFD81B60) : Colors.black87)),
    ]);
  }

  Widget _formularioPago() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.credit_card, color: Color(0xFFFF69B4)), SizedBox(width: 8), Text('Método de Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
            const SizedBox(height: 16),
            _opcionPago('tarjeta_simulada', 'Tarjeta de Crédito/Débito (Simulada)', Icons.credit_card),
            const SizedBox(height: 8),
            _opcionPago('contraentrega', 'Pago contra entrega (Efectivo)', Icons.money),
            if (_metodoPago == 'tarjeta_simulada') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '4242 4242 4242 4242',
                  prefixIcon: const Icon(Icons.credit_card, color: Color(0xFFFF69B4)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF69B4))),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
                onChanged: (value) => setState(() => _tarjetaNumero = value),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el número de tarjeta';
                  final clean = value.replaceAll(RegExp(r'\s+'), '');
                  if (clean.length != 16) return 'Ingrese 16 dígitos';
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _TarjetaFormatter(),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(12)),
                child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Color(0xFFFF69B4)), SizedBox(width: 8), Expanded(child: Text('Simulación: Cualquier número de 16 dígitos es válido', style: TextStyle(fontSize: 12, color: Colors.grey)))]),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _opcionPago(String valor, String label, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _metodoPago = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _metodoPago == valor ? const Color(0xFFFF69B4).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _metodoPago == valor ? const Color(0xFFFF69B4) : Colors.grey.shade300),
        ),
        child: Row(children: [
          Radio<String>(value: valor, groupValue: _metodoPago, onChanged: (v) => setState(() => _metodoPago = v!), activeColor: const Color(0xFFFF69B4)),
          Icon(icon, size: 20, color: _metodoPago == valor ? const Color(0xFFFF69B4) : Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: _metodoPago == valor ? FontWeight.w500 : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _botonPagar(PayProvider payProvider) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: payProvider.processing ? null : _procesarPago,
        icon: payProvider.processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle, color: Colors.white),
        label: Text(payProvider.processing ? 'Procesando pago...' : 'Confirmar Pago', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF69B4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFFFF69B4).withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _carritoVacio() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('El carrito está vacío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Agrega productos para continuar'),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF69B4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Ir al catálogo', style: TextStyle(color: Colors.white))),
      ]),
    );
  }
}

class _TarjetaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\s+'), '');
    if (text.isEmpty) return newValue;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}