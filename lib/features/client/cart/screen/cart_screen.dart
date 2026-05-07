import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar items al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().cargar();
    });
  }

  void _showSoon(String f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('🚧 $f — ¡Próximamente!'),
    backgroundColor: const Color(0xFFFF69B4),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  ));

  Future<bool> _confirmDelete(String itemId, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar producto?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
        content: Text('¿Deseas eliminar "$nombre" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<CartProvider>().eliminar(itemId);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFF69B4)),
          const SizedBox(width: 10),
          const Text('Mi Carrito',
              style: TextStyle(color: Color(0xFFD81B60),
                  fontWeight: FontWeight.bold, fontSize: 20)),
          if (cart.totalItems > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${cart.totalItems} items',
                  style: const TextStyle(color: Color(0xFFFF69B4),
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFD81B60)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('¿Vaciar carrito?',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
                    content: const Text('Se eliminarán todos los productos del carrito.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Vaciar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) await context.read<CartProvider>().vaciar();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              label: const Text('Vaciar', style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
          : cart.items.isEmpty
              ? _emptyCart()
              : Column(
                  children: [
                    Expanded(child: _itemsList(cart)),
                    _resumenTotal(cart),
                  ],
                ),
    );
  }

  // ── Carrito vacío ──────────────────────────────────────────
  Widget _emptyCart() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 110, height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFFF69B4).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.shopping_bag_outlined,
            size: 55, color: Color(0xFFFF69B4)),
      ),
      const SizedBox(height: 20),
      const Text('Tu carrito está vacío',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60))),
      const SizedBox(height: 8),
      const Text('Agrega productos desde el catálogo',
          style: TextStyle(fontSize: 14, color: Colors.black45)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.store_outlined, color: Colors.white),
        label: const Text('Ir al catálogo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF69B4),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 3,
        ),
      ),
    ]),
  );

  // ── Lista de items ─────────────────────────────────────────
  Widget _itemsList(CartProvider cart) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: cart.items.length,
    itemBuilder: (_, i) {
      final item    = cart.items[i];
      final itemId  = item['id'] as String;
      final producto = item['producto'] as Map<String, dynamic>;
      final nombre  = producto['nombre'] as String;
      final imagen  = producto['imagen_url'] as String?;
      final stock   = producto['stock'] as int;
      final marca   = producto['marca']?['nombre'] as String? ?? '';
      final cantidad = item['cantidad'] as int;
      final precio  = (item['precio_unitario'] as num).toDouble();
      final subtotal = cantidad * precio;

      return Dismissible(
        key: Key(itemId),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(itemId, nombre).then((_) => false),
        background: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08),
                blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF69B4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: imagen != null && imagen.isNotEmpty
                      ? Image.network(imagen, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.spa,
                              color: Color(0xFFFF69B4), size: 36))
                      : const Icon(Icons.spa, color: Color(0xFFFF69B4), size: 36),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 14),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (marca.isNotEmpty)
                      Text(marca,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    Text('Bs. ${precio.toStringAsFixed(2)} c/u',
                        style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Controles cantidad
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F5),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFFFB6C1)),
                          ),
                          child: Row(children: [
                            // Botón -
                            _qtyBtn(
                              icon: Icons.remove,
                              onTap: () => context.read<CartProvider>()
                                  .actualizar(itemId, cantidad - 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('$cantidad',
                                  style: const TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                            // Botón +
                            _qtyBtn(
                              icon: Icons.add,
                              onTap: cantidad < stock
                                  ? () => context.read<CartProvider>()
                                      .actualizar(itemId, cantidad + 1)
                                  : null,
                              disabled: cantidad >= stock,
                            ),
                          ]),
                        ),

                        // Subtotal
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Text('Subtotal',
                              style: TextStyle(fontSize: 11, color: Colors.black38)),
                          Text('Bs. ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFFD81B60),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ]),
                      ],
                    ),

                    if (stock <= 3 && stock > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('¡Solo quedan $stock en stock!',
                            style: const TextStyle(fontSize: 11,
                                color: Colors.orange, fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                onPressed: () => _confirmDelete(itemId, nombre),
                icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
              ),
            ]),
          ),
        ),
      );
    },
  );

  Widget _qtyBtn({required IconData icon, VoidCallback? onTap, bool disabled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: disabled ? Colors.grey[200] : const Color(0xFFFF69B4).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 16,
            color: disabled ? Colors.grey : const Color(0xFFD81B60)),
      ),
    );
  }

  // ── Resumen total ──────────────────────────────────────────
  Widget _resumenTotal(CartProvider cart) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1),
          blurRadius: 20, offset: const Offset(0, -4))],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Línea decorativa
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Subtotal:', style: TextStyle(fontSize: 15, color: Colors.black54)),
          Text('Bs. ${cart.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Envío:', style: TextStyle(fontSize: 15, color: Colors.black54)),
          const Text('A calcular', style: TextStyle(fontSize: 14, color: Colors.orange)),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFFFE4E9)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total:', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
          Text('Bs. ${cart.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: Color(0xFFD81B60))),
        ]),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _showSoon('Checkout'),
            icon: const Icon(Icons.payment_rounded, color: Colors.white),
            label: const Text('Proceder al pago',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: const Color(0xFFFF69B4).withOpacity(0.4),
            ),
          ),
        ),
      ],
    ),
  );
}