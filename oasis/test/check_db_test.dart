import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Supabase booking insert test without select', () async {
    SharedPreferences.setMockInitialValues({});
    print('Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://qmsiwwptlxweuwxnoqoz.supabase.co',
      anonKey: 'sb_publishable_-egovRSMG7eERRV5rToWMA_uby5b4Pi',
    );
    final client = Supabase.instance.client;
    
    final date = DateTime.now().add(const Duration(days: 6));
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    print('Inserting WITHOUT select...');
    try {
      await client.from('bookings').insert({
        'customer_name': 'Test Customer No Select',
        'customer_email': 'testnoselect@example.com',
        'treatment_id': 1,
        'booking_date': dateStr,
        'start_time': '10:00:00',
        'end_time': '11:00:00',
        'room_number': 1,
        'status': 'confirmed',
      });
      print('-> Success! Insert without select completed.');
    } catch (e, stack) {
      print('-> ERROR inserting without select: $e\n$stack');
    }
  });
}
