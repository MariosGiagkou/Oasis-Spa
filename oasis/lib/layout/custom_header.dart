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
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        _buildNavButton(context, 'Main', const MainPage()),
        _buildNavButton(context, 'Menu', const MenuPage()),
        _buildNavButton(context, 'Book With Us', const BookPage()),
        _buildNavButton(context, 'About Us', const AboutPage()),
        const SizedBox(width: 16), // Right padding
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
