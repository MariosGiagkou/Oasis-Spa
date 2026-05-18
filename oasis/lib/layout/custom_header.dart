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
        child: const SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Oasis',
                  style: TextStyle(
                    fontFamily:
                        'Times New Roman', // Classic, elegant serif font
                    fontSize: 26, // Scaled down
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 6.0,
                        color: Colors.black45,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                Text(
                  'SPA & WELLNESS',
                  style: TextStyle(
                    fontFamily:
                        'Times New Roman', // Classic serif font for the subtitle
                    fontSize: 9, // Scaled down
                    letterSpacing: 4.0, // Subtly spread out
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black45,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0); // Adjusted height for smaller text
}
