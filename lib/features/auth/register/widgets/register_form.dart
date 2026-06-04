import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController nombre;
  final TextEditingController apellido;
  final TextEditingController email;
  final TextEditingController telefono;
  final TextEditingController direccion;
  final TextEditingController password;
  final TextEditingController confirmPassword;

  final bool isLoading;
  final VoidCallback onSubmit;

  const RegisterForm({
    super.key,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.password,
    required this.confirmPassword,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: nombre, decoration: const InputDecoration(labelText: "Nombre")),
        TextField(controller: apellido, decoration: const InputDecoration(labelText: "Apellido")),
        TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
        TextField(controller: telefono, decoration: const InputDecoration(labelText: "Teléfono")),
        TextField(controller: direccion, decoration: const InputDecoration(labelText: "Dirección")),
        TextField(controller: password, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
        TextField(controller: confirmPassword, decoration: const InputDecoration(labelText: "Confirmar Password"), obscureText: true),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Registrarse"),
        ),
      ],
    );
  }
}