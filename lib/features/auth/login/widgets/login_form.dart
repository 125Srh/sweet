import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget{
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Correo'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Contraseña'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : onLogin,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Iniciar sesión'),
        ),
      ],
    );
  }
}