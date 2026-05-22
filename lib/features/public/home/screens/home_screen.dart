import 'package:flutter/material.dart';
import 'package:sweet/features/auth/register/screens/register_admin_screen.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F0FF), Color(0xFFFFE6F0)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ LOGO (ícono temporal)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF69B4).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.spa, // ← Cambia por tu logo real
                  size: 70,
                  color: Color(0xFFFF69B4),
                ),
              ),
              const SizedBox(height: 20),

              // 📝 TEXTO DE MARCA
              const Text(
                'Sweet',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: Color(0xFFD81B60),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu tienda de belleza favorita',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 60),

              // Botones...
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login, size: 20),
                label: const Text('Iniciar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF69B4),
                  minimumSize: const Size(220, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterAdminScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings, size: 20),
                label: const Text('Crear Admin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF69B4),
                  side: const BorderSide(color: Color(0xFFFF69B4), width: 2),
                  minimumSize: const Size(220, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
