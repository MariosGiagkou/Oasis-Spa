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
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

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
    
    // Stub the Future/Stream matching the builder's then method
    when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Function;
      return callback([]);
    });

    SupabaseService.mockClient = mockClient;

    await tester.pumpWidget(const MaterialApp(
      home: AdminPage(),
    ));

    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('Admin Dashboard'), findsOneWidget);

    // Verify config card exists
    expect(find.text('Active Personnel'), findsOneWidget);

    // Verify Refresh and Logout buttons exist
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
