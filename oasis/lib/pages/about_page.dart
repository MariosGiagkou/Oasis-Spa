import 'package:flutter/material.dart';

class AboutPageBody extends StatelessWidget {
  const AboutPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Image.asset(
            'lib/menu/Screenshot 2026-05-18 153824.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Image.asset(
            'lib/banner/banner1.png',
            width: double.infinity,
            fit: BoxFit.cover, // Fills in the remaining space seamlessly
          ),
        ),
      ],
    );
  }
}
