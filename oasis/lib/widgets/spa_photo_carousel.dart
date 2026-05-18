import 'package:flutter/material.dart';
import '../data/spa_theme.dart';

/// A horizontally scrollable photo carousel showcasing spa images.
/// Uses the pictures from the "main page pics" asset folder.
class SpaPhotoCarousel extends StatelessWidget {
  const SpaPhotoCarousel({super.key});

  static const List<String> _images = [
    'lib/main page pics/reception spa.jpg',
    'lib/main page pics/couch spa.png',
    'lib/main page pics/saouna spa.jpg',
    'lib/main page pics/door_spa.jpg',
  ];

  static const List<String> _captions = [
    'Reception',
    'Relaxation Lounge',
    'Sauna & Steam',
    'Entrance',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _PhotoCard(
            assetPath: _images[index],
            caption: _captions[index],
          );
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String assetPath;
  final String caption;

  const _PhotoCard({required this.assetPath, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            assetPath,
            width: 200,
            height: 170,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: SpaColors.terracotta,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
