import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/widgets/spa_photo_carousel.dart';

void main() {
  testWidgets('SpaPhotoStrip renders multiple photos in a Column', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SpaPhotoStrip(),
        ),
      ),
    ));

    // Verify it renders a Column widget (which is what SpaPhotoStrip returns)
    expect(find.byType(Column), findsWidgets);
    
    // Check for standard images from the carousel
    // The widget loads these assets:
    // 'lib/main page pics/couch spa.png'
    // 'lib/main page pics/reception spa.jpg'
    // 'lib/main page pics/door_spa.jpg'
    // 'lib/main page pics/saouna spa.jpg'
    expect(find.byType(Image), findsWidgets);
  });
}
