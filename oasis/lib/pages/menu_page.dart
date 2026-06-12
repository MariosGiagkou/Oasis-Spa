import 'package:flutter/material.dart';

class MenuPageBody extends StatelessWidget {
  const MenuPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Image.asset(
              'lib/menu/menu0.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            Image.asset(
              'lib/menu/menubody.png',
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
        ),
      ),
    );
  }
}
