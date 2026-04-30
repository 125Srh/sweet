import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color.fromARGB(255, 255, 19, 98);

    return AppBar(
      backgroundColor: pinkColor,
      elevation: 0,
      title: const Text(
        'MiTienda',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.print), onPressed: () {}),
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),

        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),

        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
