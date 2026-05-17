import 'package:flutter/material.dart';
import '../layout/custom_header.dart';
import '../data/spa_menu_data.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: spaMenu.length,
        itemBuilder: (context, index) {
          final treatment = spaMenu[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            color: Colors.white, // keep it clean
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723), // Dark brown
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    treatment.durationAndPrice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary, // Brownish accent
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    treatment.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
