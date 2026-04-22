import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sweet/features/auth/register/providers/register_provider.dart';

class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RegisterProvider>();

    final error = await provider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      data: {
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'rol': 'admin', // 🔥 AQUÍ CAMBIA TODO
      },
    );
    // 👇 DEBUG EN CONSOLA
    if (error == null) {
      print("✅ REGISTRO EXITOSO");
    } else {
      print("❌ ERROR REGISTER: $error");
    }

    if (error == null) {
      _showSnackBar('✅ Admin registrado correctamente', false);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/login');
        }
      });
    } else {
      _showSnackBar(error, true);
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RegisterProvider>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5F7), Color(0xFFFFE4E9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // LOGO
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 60,
                        color: Color(0xFFFF69B4),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Crear Admin',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FORM
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          _input(_nombreController, 'Nombre'),
                          _input(_apellidoController, 'Apellido'),
                          _input(_emailController, 'Correo electrónico'),
                          _input(_telefonoController, 'Teléfono'),
                          _input(_direccionController, 'Dirección'),
                          _passwordField(),
                          _confirmPasswordField(),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF69B4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Registrar Admin',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
    );
  }
}
