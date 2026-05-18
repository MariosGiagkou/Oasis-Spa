import 'package:flutter/material.dart';
import '../data/spa_theme.dart';

/// Displays spa photos in an alternating left / right layout
/// woven between content, giving an editorial magazine feel.
class SpaPhotoStrip extends StatelessWidget {
  const SpaPhotoStrip({super.key});

  static const List<String> _images = [
    'lib/main page pics/reception spa.jpg',
    'lib/main page pics/couch spa.png',
    'lib/main page pics/saouna spa.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_images.length, (i) {
        final isLeft = i.isEven;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Align(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: SpaColors.terracotta.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _images[i],
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
