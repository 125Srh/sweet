import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://olknfwrgwfxfujmrrdpk.supabase.co',
    anonKey: 'sb_publishable_UA-j1pS5YTaaARe',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet - MiTienda',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProductsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}