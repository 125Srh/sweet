import 'package:flutter/material.dart';

class SwipeToCartButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  final int stock;

  const SwipeToCartButton({
    super.key,
    required this.onConfirmed,
    required this.stock,
  });

  @override
  State<SwipeToCartButton> createState() => _SwipeToCartButtonState();
}

class _SwipeToCartButtonState extends State<SwipeToCartButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _completed = false;

  bool get _sinStock => widget.stock <= 0;

  void _showNoStockFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.remove_shopping_cart, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Producto sin stock disponible'),
          ],
        ),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _sinStock
              ? [Colors.grey.shade300, Colors.grey.shade400]
              : _completed
                  ? [
                      const Color.fromARGB(255, 160, 2, 246),
                      const Color.fromARGB(255, 160, 2, 246),
                    ]
                  : [
                      const Color(0xFFF48FB1),
                      const Color(0xFFCE93D8),
                    ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _sinStock
                ? Colors.grey.withOpacity(0.2)
                : Colors.pink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TEXTO
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _sinStock
                  ? 'Sin stock disponible'
                  : _completed
                      ? 'Agregado al carrito '
                      : 'Desliza para comprar ',
              key: ValueKey(_sinStock ? 'nostock' : _completed.toString()),
              style: TextStyle(
                color: _sinStock ? Colors.grey[600] : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // BOTÓN DESLIZABLE
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: _sinStock
                  ? null
                  : (details) {
                      if (_completed) return;
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > 260) _dragPosition = 260;
                      });
                    },
              onHorizontalDragEnd: _sinStock
                  ? null
                  : (details) {
                      if (_dragPosition > 230) {
                        setState(() {
                          _dragPosition = 260;
                          _completed = true;
                        });

                        widget.onConfirmed();

                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _dragPosition = 0;
                              _completed = false;
                            });
                          }
                        });
                      } else {
                        setState(() => _dragPosition = 0);
                      }
                    },
              onTap: _sinStock ? _showNoStockFeedback : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _sinStock
                      ? Icons.remove_shopping_cart_outlined
                      : _completed
                          ? Icons.check
                          : Icons.arrow_forward_ios,
                  color: _sinStock
                      ? Colors.grey[400]
                      : _completed
                          ? const Color.fromARGB(255, 217, 0, 255)
                          : const Color(0xFFD81B60),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}