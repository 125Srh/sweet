import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sweet/features/admin/home/screens/admin_home_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_clients_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_notifications_screen.dart';
import 'package:sweet/features/admin/home/screens/admin_orders_screen.dart';
import 'package:sweet/features/admin/sarahi/screens/reporte_ventas_screen.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';
import 'package:sweet/features/auth/login/screens/login_admin_screen.dart';
import 'package:sweet/features/auth/register/screens/register_admin_screen.dart';
import 'package:sweet/features/auth/register/screens/register_screen.dart';
import 'package:sweet/features/client/home/screen/client_home_screen.dart';
import 'package:sweet/features/client/home/screen/client_detail_screen.dart';
import 'package:sweet/features/public/home/screens/home_screen.dart';

final _supabase = Supabase.instance.client;

final router = GoRouter(
  initialLocation: "/home",
  redirect: (context, state) async {
    final session = _supabase.auth.currentSession;
    final isLoggedIn = session != null;

    // Rutas públicas
    final isPublicRoute =
        state.matchedLocation == '/home' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/admin-login' ||
        state.matchedLocation == '/admin-register';

    // Si está logueado, obtener su rol
    if (isLoggedIn) {
      String rol = 'cliente';
      try {
        final userData = await _supabase
            .from('usuario')
            .select('rol')
            .eq('id', session.user.id)
            .maybeSingle();
        rol = userData?['rol'] ?? 'cliente';
      } catch (e) {
        rol = 'cliente';
      }

      // Si está en ruta pública, redirigir según su rol
      if (isPublicRoute) {
        return rol == 'admin' ? '/admin' : '/client';
      }

      // Si es admin y está en ruta de cliente, redirigir a admin
      if (rol == 'admin' && state.matchedLocation.startsWith('/client')) {
        return '/admin';
      }

      // Si es cliente y está en ruta de admin, redirigir a cliente
      if (rol == 'cliente' && state.matchedLocation.startsWith('/admin')) {
        return '/client';
      }
    }

    // No logueado y quiere entrar a ruta protegida
    final isProtectedRoute =
        state.matchedLocation == '/client' ||
        state.matchedLocation.startsWith('/client/') ||
        state.matchedLocation == '/admin' ||
        state.matchedLocation.startsWith('/admin/') ||
        state.matchedLocation == '/reportes';

    if (!isLoggedIn && isProtectedRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    // Pantallas públicas
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const LoginAdminScreen(),
    ),
    GoRoute(
      path: '/admin-register',
      builder: (context, state) => const RegisterAdminScreen(),
    ),

    // Pantallas de cliente
    GoRoute(
      path: '/client',
      builder: (context, state) => const ClientHomeScreen(),
    ),
    GoRoute(
      path: '/client/producto/:id',
      builder: (context, state) {
        final product = state.extra as Map<String, dynamic>;
        return ClientDetailScreen(product: product);
      },
    ),

    // Pantallas de administrador
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
      path: '/admin/pedidos',
      builder: (context, state) => const AdminOrdersScreen(),
    ),
    GoRoute(
      path: '/reportes',
      builder: (context, state) => const ReporteVentasScreen(),
    ),
  ],
);
