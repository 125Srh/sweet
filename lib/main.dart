import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 INICIALIZAR SUPABASE (OBLIGATORIO)
  await Supabase.initialize(
    url: 'https://olknfwrgwfxufjmrrdpk.supabase.co',
    anonKey: 'sb_publishable_UA-j1pS5YTaaAReVTOnWSQ_ZA6gS4Ce',
  );

  runApp(const SweetApp());
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
    );
  }
}
