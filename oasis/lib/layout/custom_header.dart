import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Oasis',
                  style: GoogleFonts.notoSerif(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: Colors.white,
                    shadows: const [
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
                  style: GoogleFonts.notoSerif(
                    fontSize: 9,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    shadows: const [
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
