import 'package:flutter/material.dart';
import '../model/user_model.dart';

class UserInfoCard extends StatelessWidget {
  final UserModel user;

  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4E9), Color(0xFFFFF5F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(Icons.spa, size: 40, color: Color(0xFFFF69B4)),
          ),

          const SizedBox(height: 15),

          Text(
            user.nombreCompleto,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD81B60),
            ),
          ),

          const SizedBox(height: 5),

          Text(user.email, style: const TextStyle(color: Colors.black54)),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip(Icons.phone, user.telefono ?? 'Sin teléfono'),
              const SizedBox(width: 10),
              _chip(Icons.location_on, user.direccion ?? 'Sin dirección'),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: user.rol == 'admin'
                  ? Colors.purple.shade100
                  : Colors.pink.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.rol.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: user.rol == 'admin' ? Colors.purple : Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.pink),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
