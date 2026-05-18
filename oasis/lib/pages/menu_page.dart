import 'package:flutter/material.dart';

class MenuPageBody extends StatelessWidget {
  const MenuPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Image.asset(
          'lib/menu/Screenshot 2026-05-18 153743.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Image.asset(
          'lib/menu/menu1.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Image.asset(
          'lib/menu/leg.jpeg',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        Image.asset(
          'lib/menu/aaaa.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ],
    );
  }
}
