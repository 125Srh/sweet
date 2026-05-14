// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:sweet/features/admin/home/screens/admin_home_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_clients_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_notifications_screen.dart';
import 'package:sweet/features/admin/sarahi/screens/reporte_ventas_screen.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';
import 'package:sweet/features/client/home/screen/client_home_screen.dart';
import 'package:sweet/features/public/home/screens/home_screen.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/admin/clientes',               // ← HU-19
      builder: (context, state) => const AdminClientsScreen(),
    ),
    GoRoute(
      path: '/admin/notificaciones',         // ← HU-22
      builder: (context, state) => const AdminNotificationsScreen(),
    ),
    GoRoute(
      path: '/client',
      builder: (context, state) => const ClientHomeScreen(),
    ),
    GoRoute(
      path: '/reportes',
      builder: (context, state) => const ReporteVentasScreen(),
    ),
  ],
);