import 'package:flutter/material.dart';
import '../data/spa_theme.dart';

class MenuPageBody extends StatelessWidget {
  const MenuPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 800) {
          return ListView(
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
                'lib/menu/leg1.jpeg',
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
        } else {
          return Row(
            children: [
              Expanded(
                child: Container(
                  color: SpaColors.sand,
                ),
              ),
              SizedBox(
                width: 800,
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
                      'lib/menu/leg1.jpeg',
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
              Expanded(
                child: Container(
                  color: const Color(0xFFC78159), // rgba(199, 129, 89)
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
