import 'package:flutter/material.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oasis Spa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D6E63), // warm brown
          surface: const Color(0xFFF5F5DC), // soft beige
          onSurface: const Color(0xFF3E2723), // dark brown text
          primary: const Color(0xFF8D6E63), // warm brown
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
