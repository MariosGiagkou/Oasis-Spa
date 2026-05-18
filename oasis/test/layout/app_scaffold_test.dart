import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/layout/app_scaffold.dart';

void main() {
  testWidgets('AppScaffold drawer navigation works', (WidgetTester tester) async {
    // Need a wide enough screen so drawer isn't modal if we want it always open,
    // but by default it's hidden and opened via AppBar icon.
    await tester.pumpWidget(const MaterialApp(
      home: AppScaffold(),
    ));

    // Verify Main page body is shown initially
    expect(find.textContaining('Welcome to Oasis Spa'), findsOneWidget);

    // Open Drawer by tapping the menu icon in the AppBar
    // The CustomHeader provides a standard hamburger icon if we don't override it,
    // actually Scaffold provides it if drawer is set.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle(); // Wait for drawer animation

    // Verify drawer items exist
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Book With Us'), findsOneWidget);
    expect(find.text('Oasis Spa - Policies & Etiquette'), findsOneWidget);

    // Tap 'Menu'
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle(); // Wait for drawer to close

    // Verify Menu page is shown (should find multiple images and NO welcome text)
    expect(find.textContaining('Welcome to Oasis Spa'), findsNothing);
  });
}
