import 'package:flutter/material.dart';
import '../layout/custom_header.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      body: ListView(
        padding: EdgeInsets.zero, // Removed the 16 padding
        children: [
          Image.asset(
            'lib/menu/Screenshot 2026-05-18 153743.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Image.asset(
            'lib/menu/Screenshot 2026-05-18 153757.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Image.asset(
            'lib/menu/Screenshot 2026-05-18 153812.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Image.asset(
            'lib/menu/Screenshot 2026-05-18 153824.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Image.asset(
            'lib/menu/Screenshot 2026-05-18 153837.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }
}
