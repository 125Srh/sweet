import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_info_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: const Color(0xFFFF69B4),
      ),
      body: user == null
          ? const Center(child: Text("No hay usuario logueado"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  UserInfoCard(user: user),

                  const SizedBox(height: 30),

                  if (user.rol == 'admin') const Text("Panel administrador 🛠"),

                  if (user.rol == 'cliente') const Text("Mis pedidos 🛍"),
                ],
              ),
            ),
    );
  }
}
