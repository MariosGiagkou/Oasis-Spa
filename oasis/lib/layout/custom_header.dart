import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Make background transparent
      elevation: 0, // Remove shadow
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 32,
      ), // Make the 3 dashes white and slightly larger
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/banner/banner1.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0); // Made banner thinner
}
