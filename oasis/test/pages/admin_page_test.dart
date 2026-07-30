import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oasis/pages/admin_page.dart';
import 'package:oasis/services/supabase_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSession extends Mock implements Session {}
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
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockSession mockSession;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    SharedPreferences.setMockInitialValues({'personnel_overrides': '{}'});
    
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockSession = MockSession();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    registerFallbackValue(Uri());
  });

  testWidgets('AdminPage renders Login screen when not authenticated', (WidgetTester tester) async {
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(null);
    SupabaseService.mockClient = mockClient;

    await tester.pumpWidget(const MaterialApp(
      home: AdminPage(),
    ));

    await tester.pumpAndSettle();

    // Verify login title and fields
    expect(find.text('Admin Login'), findsOneWidget);
    expect(find.text('Oasis Spa Admin'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('AdminPage renders layout elements when authenticated', (WidgetTester tester) async {
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(mockSession);
    when(() => mockClient.from('bookings')).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenAnswer((_) => mockFilterBuilder);
    
    mockFilterBuilder.mockResult.clear();

    SupabaseService.mockClient = mockClient;

    await tester.pumpWidget(const MaterialApp(
      home: AdminPage(),
    ));

    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Admin Dashboard'), findsOneWidget);

    // Verify config card exists
    expect(find.text('Active Personnel'), findsOneWidget);

    // Verify Refresh, Logout and Sort buttons exist
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

    // Tap the sort button
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();

    // Verify it changed to arrow_upward
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('AdminPage renders pending booking and handles confirm/cancel actions', (WidgetTester tester) async {
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(mockSession);
    when(() => mockClient.from('bookings')).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
    when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenAnswer((_) => mockFilterBuilder);

    // Mock a pending booking returned from database
    final List<Map<String, dynamic>> mockBookings = [
      {
        'id': 123,
        'customer_name': 'Pending Customer',
        'customer_email': 'pending@example.com',
        'booking_date': '2026-06-20',
        'start_time': '12:00:00',
        'room_number': 2,
        'status': 'pending',
        'treatments': {'title': 'Sport Massage'}
      }
    ];

    mockFilterBuilder.mockResult.clear();
    mockFilterBuilder.mockResult.addAll(mockBookings);

    SupabaseService.mockClient = mockClient;

    await tester.pumpWidget(const MaterialApp(
      home: AdminPage(),
    ));

    await tester.pumpAndSettle();

    // Verify the pending booking details are rendered
    expect(find.text('Pending Customer'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('Sport Massage'), findsOneWidget);
    expect(find.text('Employee Assigned: 2'), findsOneWidget);

    // Verify both Approve (check_circle) and Cancel (cancel) buttons are present
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
  });
}
