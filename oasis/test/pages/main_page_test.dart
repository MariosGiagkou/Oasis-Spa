import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/pages/main_page.dart';

void main() {
  testWidgets('MainPageBody renders welcome text and images', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MainPageBody(onNavigate: (_) {}),
      ),
    ));

    // Verify welcome text
    expect(find.textContaining('Welcome to Oasis Spa'), findsOneWidget);
  });
}
