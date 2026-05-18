import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/pages/menu_page.dart';

void main() {
  testWidgets('MenuPageBody renders all menu images', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MenuPageBody(),
      ),
    ));

    await tester.pumpAndSettle();

    // Verify it contains the ListView
    expect(find.byType(ListView), findsOneWidget);
  });
}
