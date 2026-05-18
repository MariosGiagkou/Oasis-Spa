import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/pages/book_page.dart';

void main() {
  testWidgets('BookPageBody rendering and Stepper flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BookPageBody(),
      ),
    ));

    // Wait for the treatments to load (which will fallback to local data in tests)
    await tester.pumpAndSettle();

    // Verify Step 1 is active and shows treatments
    expect(find.text('Choose Treatment'), findsOneWidget);
    expect(find.text('Classic Relaxation Massage (60 min)'), findsOneWidget);

  });
}
