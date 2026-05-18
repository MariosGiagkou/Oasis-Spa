import 'package:flutter/material.dart';
import 'layout/app_scaffold.dart';

void main() {
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
