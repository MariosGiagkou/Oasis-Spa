import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/pages/admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'total_rooms': 3});
  });

  testWidgets('AdminPage renders layout elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AdminPage(),
    ));

    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Admin Dashboard'), findsOneWidget);

    // Verify config card exists
    expect(find.text('Active Personnel'), findsOneWidget);

    // Verify Refresh button exists
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
