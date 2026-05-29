import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sweet/features/client/home/provider/client_provider.dart';
import 'package:sweet/features/client/home/provider/notification_provider.dart'; // 👈 nuevo
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

import 'package:provider/provider.dart';
import 'package:sweet/features/auth/register/providers/register_provider.dart';
import 'package:sweet/features/admin/home/providers/admin_provider.dart';
import 'package:sweet/features/client/cart/provider/cart_provider.dart';
import 'package:sweet/features/client/address_old_backup/providers/address_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://olknfwrgwfxufjmrrdpk.supabase.co',
    anonKey: 'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => AdminsProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ), // 👈 nuevo
      ],
      child: const SweetApp(),
    ),
  );
}

class SweetApp extends StatelessWidget {
  const SweetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sweet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      scaffoldMessengerKey: messengerKey,
    );
  }
}

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
