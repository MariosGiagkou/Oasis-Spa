import 'package:flutter/material.dart';
import 'custom_header.dart';
import '../pages/main_page.dart';
import '../pages/menu_page.dart';
import '../pages/book_page.dart';
import '../pages/about_page.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;

  /// Build pages on the fly so MainPageBody always receives
  /// the current navigation callback.
  List<Widget> get _pages => [
    MainPageBody(onNavigate: _navigateToPage),
    const MenuPageBody(),
    const BookPageBody(),
    const AboutPageBody(),
  ];

  /// Called from the main page nav buttons (no drawer to close).
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close the drawer after selecting an item
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/scaffolding/spa_logo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: null,
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Main'),
              onTap: () => _onItemTapped(0),
              selected: _selectedIndex == 0,
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Menu'),
              onTap: () => _onItemTapped(1),
              selected: _selectedIndex == 1,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Book With Us'),
              onTap: () => _onItemTapped(2),
              selected: _selectedIndex == 2,
            ),
            ListTile(
              leading: const Icon(Icons.yard),
              title: const Text('Oasis Spa - Policies & Etiquette'),
              onTap: () => _onItemTapped(3),
              selected: _selectedIndex == 3,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
