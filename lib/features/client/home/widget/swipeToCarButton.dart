import 'package:flutter/material.dart';

class SwipeToCartButton extends StatefulWidget {
  final VoidCallback onConfirmed;

  const SwipeToCartButton({super.key, required this.onConfirmed});

  @override
  State<SwipeToCartButton> createState() => _SwipeToCartButtonState();
}

class _SwipeToCartButtonState extends State<SwipeToCartButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _completed
              ? [
                  const Color.fromARGB(255, 160, 2, 246), // verde suave
                  const Color.fromARGB(255, 160, 2, 246),
                ]
              : [
                  const Color(0xFFF48FB1), // rosado pastel
                  const Color(0xFFCE93D8), // lila pastel
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
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
              _completed ? 'Agregado al carrito 💖' : 'Desliza para comprar ✨',
              key: ValueKey(_completed),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // BOTÓN DESLIZABLE
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (_completed) return;

                setState(() {
                  _dragPosition += details.delta.dx;
                  if (_dragPosition < 0) _dragPosition = 0;
                  if (_dragPosition > 260) _dragPosition = 260;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragPosition > 230) {
                  setState(() {
                    _dragPosition = 260;
                    _completed = true;
                  });

                  widget.onConfirmed();

                  // 🔥 RESET BONITO DESPUÉS
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      _dragPosition = 0;
                      _completed = false;
                    });
                  });
                } else {
                  setState(() {
                    _dragPosition = 0;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _completed ? Icons.check : Icons.arrow_forward_ios,
                  color: _completed
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
