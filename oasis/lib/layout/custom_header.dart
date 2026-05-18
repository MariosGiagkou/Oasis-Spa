import 'package:flutter/material.dart';
import '../pages/main_page.dart';
import '../pages/menu_page.dart';
import '../pages/book_page.dart';
import '../pages/about_page.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Oasis Spa'),
      backgroundColor: Colors.transparent, // Make background transparent
      elevation: 0, // Remove shadow
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/banner/image.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                _buildNavButton(context, 'Main', const MainPage()),
                _buildNavButton(context, 'Menu', const MenuPage()),
                _buildNavButton(context, 'Book With Us', const BookPage()),
                _buildNavButton(context, 'About Us', const AboutPage()),
                const SizedBox(width: 16), // Right padding
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String title, Widget? page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () {
          if (page != null) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else {
            print('$title button pressed');
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: Text(title),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0); // Reduced height banner
}
