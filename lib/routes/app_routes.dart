import 'package:go_router/go_router.dart';
import 'package:sweet/features/admin/home/screens/admin_home_screen.dart';
import 'package:sweet/features/admin/sarahi/admin2/products_screen.dart';
import 'package:sweet/features/auth/login/screens/login_page.dart';
import 'package:sweet/features/client/home/screen/client_home_screen.dart';
import 'package:sweet/features/public/home/screens/home_screen.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(path: '/home', builder: (contex, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (contex, state) => const LoginPage()),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/client',
      builder: (contex, state) => const ClientHomeScreen(),
    ),
    GoRoute(
      path: '/admin2',
      builder: (context, state) {
        final tab = state.uri.queryParameters['tab'];
        final initialIndex = tab == 'reportes' ? 4 : 1;
        return ProductsScreen(initialMenuIndex: initialIndex);
      },
    ),
  ],
);