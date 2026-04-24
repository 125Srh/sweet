import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet/features/auth/login/providers/auth_provider.dart';
import 'login_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _provider = AuthProvider();

  bool isLoading = false;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Completa los campos')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final rol = await _provider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (rol == 'admin') {
        context.go('/admin2');
      } else if (rol == 'cliente') {
        context.go('/client');
      } else {
        throw Exception('Rol no válido');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      emailController: emailController,
      passwordController: passwordController,
      isLoading: isLoading,
      onLogin: login,
      title: 'Sweet',
      subtitle: 'Tu tienda de belleza favorita',
    );
  }
}
