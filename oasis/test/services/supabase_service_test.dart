import 'package:flutter_test/flutter_test.dart';
import 'package:oasis/services/supabase_service.dart';

void main() {
  group('SupabaseService', () {
    test('fetchTreatments falls back to local data when Supabase fails', () async {
      // Without initializing Supabase, this will fail and should return the fallback menu
      final treatments = await SupabaseService.fetchTreatments();
      
      expect(treatments.isNotEmpty, isTrue);
      expect(treatments.length, greaterThan(0));
      expect(treatments.first.title, contains('Classic Relaxation Massage'));
    });

    test('allTimeSlots generates correct 30-min slots from 10 to 18', () {
      final slots = SupabaseService.allTimeSlots();
      
      expect(slots.isNotEmpty, isTrue);
      expect(slots.first, '10:00:00');
      expect(slots.last, '17:30:00');
      expect(slots.length, (18 - 10) * 2);
    });

    test('availableSlots returns all slots if no bookings exist', () async {
      final date = DateTime(2026, 1, 1);
      // fetchBookingsForDate will fail and return []
      final slots = await SupabaseService.availableSlots(date, 60); // 60 min treatment
      
      expect(slots.isNotEmpty, isTrue);
      // The last slot for a 60 min treatment starting before 18:00 is 17:00
      expect(slots.last, '17:00:00'); 
    });
  });
}
