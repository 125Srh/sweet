import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class AddToCartButton extends StatefulWidget {
  final String productoId;
  final String productoNombre;
  final double precio;
  final int stock;
  final bool compact;

  const AddToCartButton({
    super.key,
    required this.productoId,
    required this.productoNombre,
    required this.precio,
    required this.stock,
    this.compact = false,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  bool _adding = false;
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _anim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.stock <= 0 || _adding) return;

    setState(() => _adding = true);
    await _ctrl.forward();
    await _ctrl.reverse();

    try {
      final cart = context.read<CartProvider>();
      final success = await cart.agregar(
        productoId: widget.productoId,
        precioUnitario: widget.precio,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.productoNombre} agregado al carrito',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFFF69B4),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (cart.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cart.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sinStock = widget.stock <= 0;

    if (widget.compact) {
      return ScaleTransition(
        scale: _anim,
        child: GestureDetector(
          onTap: sinStock ? null : _onTap,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: sinStock
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
                    ),
              color: sinStock ? Colors.grey[300] : null,
              shape: BoxShape.circle,
              boxShadow: sinStock
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFFFF69B4).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: _adding
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _anim,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: sinStock ? null : _onTap,
          icon: _adding
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.shopping_cart_outlined, size: 18),
          label: Text(
            sinStock ? 'Sin stock' : 'Agregar al carrito',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: sinStock
                ? Colors.grey[300]
                : const Color(0xFFFF69B4),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: sinStock ? 0 : 2,
          ),
        ),
      ),
    );
  }
}

class CartBadge extends StatelessWidget {
  final VoidCallback onTap;
  const CartBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final total = context.watch<CartProvider>().totalItems;
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF69B4)),
          if (total > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFD81B60),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    total > 99 ? '99+' : '$total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
