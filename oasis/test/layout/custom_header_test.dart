import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/layout/custom_header.dart';

void main() {
  testWidgets('CustomHeader renders app bar with title texts', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        appBar: CustomHeader(),
        body: Text('Body'),
      ),
    ));

    // Verify it renders the custom title parts
    expect(find.text('Oasis'), findsOneWidget);
    expect(find.text('SPA & WELLNESS'), findsOneWidget);

    // Verify background image container exists (indirectly via DecorationImage check if needed)
    // But testing texts and the widget itself is sufficient for coverage.
  });
}
