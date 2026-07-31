import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oasis/pages/book_page.dart';
import 'package:oasis/services/supabase_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> mockResult = [];

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) async {
    return await onValue(mockResult);
  }
}

void main() {
  testWidgets('BookPageBody rendering and Stepper flow', (WidgetTester tester) async {
    final mockClient = MockSupabaseClient();
    final mockQueryBuilder = MockSupabaseQueryBuilder();
    final mockFilterBuilder = MockPostgrestFilterBuilder();

    when(() => mockClient.from('bookings')).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);

    SupabaseService.mockClient = mockClient;

    // Increase surface size to ensure vertical Stepper fits in bounds and scroll works
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BookPageBody(),
      ),
    ));

    // Wait for the treatments to load (which will fallback to local data in tests)
    await tester.pumpAndSettle();

    // Verify Step 1 is active and shows treatments
    expect(find.text('Choose Treatment'), findsOneWidget);
    await tester.tap(find.text('Classic Relaxation Massage (60 min)'));
    await tester.pumpAndSettle();

    // Tap Continue to go to Step 2
    final continueBtn = find.text('Continue').first;
    await tester.ensureVisible(continueBtn);
    await tester.pumpAndSettle();
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Verify Step 2 is active
    expect(find.text('Pick Date & Time', skipOffstage: false), findsOneWidget);
    
    // Open Date Picker
    final datePickerBtn = find.byIcon(Icons.calendar_today);
    await tester.ensureVisible(datePickerBtn);
    await tester.pumpAndSettle();
    await tester.tap(datePickerBtn);
    await tester.pumpAndSettle();
    
    // In material 3 date picker, 'OK' confirms the selection
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Select time slot (fallback slots: 10:00 AM)
    final timeSlot = find.text('10:00 AM');
    await tester.ensureVisible(timeSlot);
    await tester.pumpAndSettle();
    await tester.tap(timeSlot);
    await tester.pumpAndSettle();

    // Now go to Step 3
    final continueBtn3 = find.text('Continue').at(1);
    await tester.ensureVisible(continueBtn3);
    await tester.pumpAndSettle();
    await tester.tap(continueBtn3);
    await tester.pumpAndSettle();

    // Now we are in Step 3. Tap Confirm Booking without filling form
    final confirmBtn = find.text('Confirm Booking').last;
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
    
    // Should show error because form is empty
    expect(find.text('Please enter your name'), findsOneWidget);

    // Fill the form
    await tester.enterText(find.byType(TextFormField).first, 'Mario');
    await tester.enterText(find.byType(TextFormField).last, 'invalid-email');
    await tester.pumpAndSettle();

    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'test@example.com');
    await tester.pumpAndSettle();
    
    // Since we picked a date, submitting will show the success dialog.
    // Bookings are created as 'pending' and await admin approval, so the
    // dialog confirms the request was sent - not that it is confirmed.
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
    expect(find.text('Booking Request Sent!'), findsOneWidget);
    
    // Dismiss dialog
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Reset surface size and mock client
    await tester.binding.setSurfaceSize(null);
    SupabaseService.mockClient = null;
  });
}
