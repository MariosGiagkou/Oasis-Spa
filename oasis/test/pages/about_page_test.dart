import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/pages/about_page.dart';

void main() {
  testWidgets('AboutPageBody renders policies and banner', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AboutPageBody(),
      ),
    ));

    // Wait for slivers to settle
    await tester.pumpAndSettle();

    // Verify it contains Image widgets (policies + banner)
    expect(find.byType(Image), findsWidgets);
  });
}
