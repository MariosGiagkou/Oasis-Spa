import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/spa_theme.dart';
import 'layout/app_scaffold.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qmsiwwptlxweuwxnoqoz.supabase.co',
    anonKey: 'sb_publishable_-egovRSMG7eERRV5rToWMA_uby5b4Pi',
  );

  // Load personnel count overrides
  final prefs = await SharedPreferences.getInstance();
  final overridesJson = prefs.getString('personnel_overrides');
  if (overridesJson != null) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(overridesJson);
      SupabaseService.personnelOverrides =
          decoded.map((key, val) => MapEntry(key, val as int));
    } catch (_) {}
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oasis Spa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSerif',
        textTheme: GoogleFonts.notoSerifTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D6E63), // warm brown
          surface: SpaColors.sand, // Match page background
          onSurface: const Color(0xFF3E2723), // dark brown text
          primary: const Color(0xFF8D6E63), // warm brown
        ),
        scaffoldBackgroundColor: SpaColors.sand, // Earthy/sand background
        useMaterial3: true,
      ),
      home: const AppScaffold(), // Now uses single scaffolding layout
    );
  }
}
