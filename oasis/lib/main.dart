import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'layout/app_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qmsiwwptlxweuwxnoqoz.supabase.co',
    anonKey: 'sb_publishable_-egovRSMG7eERRV5rToWMA_uby5b4Pi',
  );
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
          surface: Colors.white, // Match screenshot background
          onSurface: const Color(0xFF3E2723), // dark brown text
          primary: const Color(0xFF8D6E63), // warm brown
        ),
        scaffoldBackgroundColor: Colors
            .white, // Setting to white to seamlessly blend with typical PDF screenshots
        useMaterial3: true,
      ),
      home: const AppScaffold(), // Now uses single scaffolding layout
    );
  }
}
