import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';
import 'package:sweet/features/auth/register/providers/register_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

    // 🔥 VALIDAR PASSWORDS
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Las contraseñas no coinciden', true);
      return;
    }

    final provider = context.read<RegisterProvider>();

    final error = await provider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      data: {
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
      },
    );
    // 👇 DEBUG EN CONSOLA
    if (error == null) {
      print("✅ REGISTRO EXITOSO");
    } else {
      print("❌ ERROR REGISTER: $error");
    }

    if (error == null) {
      _showSnackBar('✅ Registro exitoso', false);

      if (!mounted) return;

      context.go('/login');
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
                        Icons.spa,
                        size: 60,
                        color: Color(0xFFFF69B4),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD81B60),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // FORM CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          _input(_nombreController, 'Nombre usuario'),
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
                                      'Registrarmee',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text("Ir a login"),
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
