// lib/features/client/cart/screen/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '/features/client/address_old_backup/screens/address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().cargar();
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
      final cart = context.read<CartProvider>();
      final success = await cart.eliminar(itemId);
      if (!mounted) return false;
      if (success) {
        _showSuccess('$nombre eliminado del carrito');
      } else if (cart.errorMessage != null) {
        _showError(cart.errorMessage!);
      }
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
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFD81B60)),
          onPressed: () => Navigator.pop(context),
        ),
        // ✅ FIX AppBar: usar PreferredSize no, sino title con Row y Expanded
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cart.items.isNotEmpty)
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: cart.allSelected,
                  onChanged: (_) => cart.toggleAll(),
                  activeColor: const Color(0xFFFF69B4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.shopping_bag_outlined, color: Color(0xFFFF69B4), size: 20),
            const SizedBox(width: 4),
            const Text(
              'Mi Carrito',
              style: TextStyle(
                color: Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (cart.totalItems > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cart.totalItems}',
                  style: const TextStyle(
                    color: Color(0xFFFF69B4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: cart.processing
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('¿Vaciar carrito?',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
                          content: const Text('Se eliminarán todos los productos del carrito.'),
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
                              child: const Text('Vaciar', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        final cartProvider = context.read<CartProvider>();
                        final success = await cartProvider.vaciar();
                        if (success) {
                          _showSuccess('Carrito vaciado correctamente');
                        } else if (cartProvider.errorMessage != null) {
                          _showError(cartProvider.errorMessage!);
                        }
                      }
                    },
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
              label: const Text('Vaciar', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF69B4)))
          : cart.items.isEmpty
              ? _emptyCart(cart)
              : Column(
                  children: [
                    if (cart.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: Colors.red[50],
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(cart.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                            GestureDetector(
                              onTap: () => cart.clearError(),
                              child: const Icon(Icons.close, color: Colors.red, size: 18),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _itemsList(cart)),
                    _resumenTotal(cart),
                  ],
                ),
    );
  }

  Widget _emptyCart(CartProvider cart) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFFF69B4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_bag_outlined, size: 55, color: Color(0xFFFF69B4)),
        ),
        const SizedBox(height: 20),
        const Text('Tu carrito está vacío',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
        const SizedBox(height: 8),
        const Text('Agrega productos desde el catálogo',
            style: TextStyle(fontSize: 14, color: Colors.black45)),
        if (cart.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(cart.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
        ],
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
      ],
    ),
  );

  Widget _itemsList(CartProvider cart) => ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: cart.items.length,
    itemBuilder: (_, i) {
      final item = cart.items[i];
      final itemId = item['id'].toString();
      final producto = item['producto'] as Map<String, dynamic>? ?? {};
      final nombre = producto['nombre']?.toString() ?? 'Producto';
      final imagen = producto['imagen_url']?.toString();
      final stock = (producto['stock'] as int?) ?? 0;
      final cantidad = (item['cantidad'] as int?) ?? 1;
      final precio = (item['precio_unitario'] as num?)?.toDouble() ?? 0.0;
      final subtotal = cantidad * precio;
      final isSelected = cart.selectedIds.contains(itemId);

      return Dismissible(
        key: Key(itemId),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(itemId, nombre).then((_) => false),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Checkbox ──
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => cart.toggleItem(itemId),
                      activeColor: const Color(0xFFFF69B4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // ── Imagen ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFFF69B4).withOpacity(0.1),
                    child: imagen != null && imagen.isNotEmpty
                        ? Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.spa, color: Color(0xFFFF69B4), size: 28),
                          )
                        : const Icon(Icons.spa, color: Color(0xFFFF69B4), size: 28),
                  ),
                ),
                const SizedBox(width: 8),

                // ── Contenido principal ──
                // ✅ FIX CLAVE: Expanded ocupa TODO el ancho restante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre + botón eliminar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _confirmDelete(itemId, nombre),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Precio unitario
                      Text(
                        'Bs. ${precio.toStringAsFixed(2)} c/u',
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                      const SizedBox(height: 6),

                      // ✅ FIX: selector de cantidad y subtotal en la MISMA fila
                      // usando spaceBetween y mainAxisSize.min en el selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Selector cantidad — mainAxisSize.min es CRÍTICO
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFFFFB6C1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // ✅ NO se expande
                              children: [
                                _qtyBtn(
                                  icon: Icons.remove,
                                  disabled: cantidad <= 1,
                                  onTap: () async {
                                    final cp = context.read<CartProvider>();
                                    final ok = await cp.decrementar(itemId);
                                    if (!ok && cp.errorMessage != null && mounted) {
                                      _showError(cp.errorMessage!);
                                    }
                                  },
                                ),
                                _EditableQuantity(
                                  cantidad: cantidad,
                                  stock: stock,
                                  processing: false,
                                  onChanged: (nv) async {
                                    final cp = context.read<CartProvider>();
                                    final ok = await cp.actualizar(itemId, nv);
                                    if (!ok && cp.errorMessage != null && mounted) {
                                      _showError(cp.errorMessage!);
                                    }
                                  },
                                ),
                                _qtyBtn(
                                  icon: Icons.add,
                                  disabled: cantidad >= stock,
                                  onTap: () async {
                                    final cp = context.read<CartProvider>();
                                    final ok = await cp.incrementar(itemId);
                                    if (!ok && cp.errorMessage != null && mounted) {
                                      _showError(cp.errorMessage!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Subtotal — sin Expanded, solo se adapta a su contenido
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 10, color: Colors.black38),
                              ),
                              Text(
                                'Bs. ${subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFD81B60),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Alerta de stock bajo
                      if (stock > 0 && stock <= 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '¡Solo quedan $stock en stock!',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _qtyBtn({
    required IconData icon,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey[200]
              : const Color(0xFFFF69B4).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: disabled ? Colors.grey : const Color(0xFFD81B60),
        ),
      ),
    );
  }

  Widget _resumenTotal(CartProvider cart) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                cart.hasSelection ? 'Subtotal (seleccionado):' : 'Subtotal:',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Bs. ${cart.hasSelection ? cart.selectedSubtotal.toStringAsFixed(2) : "0.00"}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Envío:', style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text(
              cart.hasSelection ? 'A calcular' : '—',
              style: TextStyle(
                fontSize: 13,
                color: cart.hasSelection ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Color(0xFFFFE4E9)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total:',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFD81B60))),
            Text(
              'Bs. ${cart.hasSelection ? cart.selectedSubtotal.toStringAsFixed(2) : "0.00"}',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFFD81B60)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: cart.hasSelection
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddressScreen()),
                    );
                  }
                : null,
            icon: const Icon(Icons.payment_rounded, color: Colors.white),
            label: Text(
              cart.hasSelection
                  ? 'Proceder al pago (${cart.selectedCount})'
                  : 'Selecciona productos',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF69B4),
              disabledBackgroundColor: Colors.grey[300],
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

// ── Widget de cantidad editable inline ───────────────────────
class _EditableQuantity extends StatefulWidget {
  final int cantidad;
  final int stock;
  final bool processing;
  final Function(int) onChanged;

  const _EditableQuantity({
    required this.cantidad,
    required this.stock,
    required this.processing,
    required this.onChanged,
  });

  @override
  State<_EditableQuantity> createState() => _EditableQuantityState();
}

class _EditableQuantityState extends State<_EditableQuantity> {
  bool _editing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.cantidad}');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) _confirmEdit();
    });
  }

  @override
  void didUpdateWidget(covariant _EditableQuantity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && widget.cantidad != oldWidget.cantidad) {
      _controller.text = '${widget.cantidad}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEdit() {
    if (widget.processing) return;
    setState(() {
      _editing = true;
      _controller.text = '${widget.cantidad}';
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
    _focusNode.requestFocus();
  }

  void _confirmEdit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 1) {
      _controller.text = '${widget.cantidad}';
    } else if (parsed > widget.stock) {
      _controller.text = '${widget.stock}';
      if (parsed != widget.cantidad) widget.onChanged(widget.stock);
    } else if (parsed != widget.cantidad) {
      widget.onChanged(parsed);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return SizedBox(
        width: 42,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD81B60)),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            isDense: true,
          ),
          onSubmitted: (_) => _confirmEdit(),
        ),
      );
    }

    return GestureDetector(
      onTap: _startEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFFF69B4).withOpacity(0.4),
              width: 1,
            ),
          ),
        ),
        child: Text(
          '${widget.cantidad}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}