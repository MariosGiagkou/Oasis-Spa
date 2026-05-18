import 'package:flutter/material.dart';

class AboutPageBody extends StatelessWidget {
  const AboutPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Image.asset(
          'lib/menu/Screenshot 2026-05-18 153824.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ],
    );
  }
}
