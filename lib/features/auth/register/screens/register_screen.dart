import 'package:flutter/material.dart';
import 'package:sweet/features/auth/register/providers/register_provider.dart';
import 'package:sweet/features/auth/register/widgets/register_form.dart'; // ✅ ESTE FALTA
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final email = TextEditingController();
  final telefono = TextEditingController();
  final direccion = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      body: RegisterForm(
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        direccion: direccion,
        password: password,
        confirmPassword: confirmPassword,
        isLoading: provider.isLoading,
        onSubmit: () async {

          final error = await provider.register(
            email: email.text.trim(),
            password: password.text.trim(),
            data: {
              'nombre': nombre.text.trim(),
              'apellido': apellido.text.trim(),
              'correo electrónico': email.text.trim(),
              'teléfono': telefono.text.trim(),
              'dirección': direccion.text.trim(),
              'rol': 'cliente', // 🔥 CLAVE
              'activo': true,
              'creado_en': DateTime.now().toIso8601String(),
              'actualizado_en': DateTime.now().toIso8601String(),
            },
          );

          if (error == null) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}