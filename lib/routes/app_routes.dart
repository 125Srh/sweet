import 'package:go_router/go_router.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';
import 'package:sweet/features/home/screens/home_screen.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(path: '/home', builder: (contex, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (contex, state) => const LoginPage()),
  ],
);
