// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:sweet/features/admin/home/screens/admin_home_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_clients_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_notifications_screen.dart';
import 'package:sweet/features/admin/sarahi/screens/reporte_ventas_screen.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';
import 'package:sweet/features/client/home/screen/client_home_screen.dart';
import 'package:sweet/features/client/home/screen/client_detail_screen.dart'; // 👈 nuevo
import 'package:sweet/features/public/home/screens/home_screen.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/admin/clientes',
      builder: (context, state) => const AdminClientsScreen(),
    ),
    GoRoute(
      path: '/admin/notificaciones',
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
    // 👇 nueva ruta para detalle de producto desde notificación
    GoRoute(
      path: '/client/producto/:id',
      builder: (context, state) {
        final product = state.extra as Map<String, dynamic>;
        return ClientDetailScreen(product: product);
      },
    ),
  ],
);
