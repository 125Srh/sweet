import 'package:flutter/material.dart';
import 'package:sweet/features/auth/login/providers/auth_provider.dart';
import 'package:sweet/features/auth/login/screens/login_screen.dart';

class LoginAdminScreen extends StatefulWidget {
  const LoginAdminScreen({super.key});

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  // 🧠 Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🧠 Provider
  final _provider = AuthProvider();

  bool _isLoading = false;

  // 🔐 LOGIN ADMIN
  Future<void> _loginAdmin() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage('Ingresa tu correo', true);
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showMessage('Ingresa tu contraseña', true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rol = await _provider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 🔥 SOLO ADMIN
      if (rol != 'admin') {
        throw Exception('No tienes permisos de administrador');
      }

      _showMessage('✅ Bienvenido Admin', false);

      // 🚀 Navegación futura
      print('Ir a panel ADMIN');
      // context.go('/admin');
    } catch (e) {
      _showMessage(e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 📢 MENSAJES
  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // (Opcional)
  // void _goToRegister() {
  //   _showMessage('Registro no disponible para admin', true);
  // }

  void _forgotPassword() {
    _showMessage('Recuperación de contraseña próximamente', false);
  }

  // 🧹 LIMPIAR MEMORIA
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreen(
        title: 'Registro Admin',
        subtitle: 'Acceso administrativo',

        emailController: _emailController,
        passwordController: _passwordController,
        isLoading: _isLoading,
        onLogin: _loginAdmin,

        // 👇 opcionales
        //onRegister: _goToRegister,
        onForgotPassword: _forgotPassword,
      ),
    );
  }
}
