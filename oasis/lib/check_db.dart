import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('Initializing Supabase...');
  await Supabase.initialize(
    url: 'https://qmsiwwptlxweuwxnoqoz.supabase.co',
    anonKey: 'sb_publishable_-egovRSMG7eERRV5rToWMA_uby5b4Pi',
  );
  final client = Supabase.instance.client;
  print('Fetching treatments...');
  try {
    final response = await client.from('treatments').select().order('id', ascending: true);
    print('Treatments count: ${response.length}');
    for (var row in response) {
      print('ID: ${row['id']}, Title: "${row['title']}", Duration: ${row['duration_minutes']}, Price: ${row['price_euros']}');
    }
  } catch (e) {
    print('Error fetching treatments: $e');
  }

  print('Fetching bookings...');
  try {
    final response = await client.from('bookings').select().limit(10);
    print('Bookings: $response');
  } catch (e) {
    print('Error fetching bookings: $e');
  }
}
