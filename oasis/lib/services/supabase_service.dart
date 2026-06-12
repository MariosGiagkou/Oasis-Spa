import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/spa_menu_data.dart';

/// Central service for all Supabase operations (treatments + bookings).
class SupabaseService {
  /// Optional mock client for testing.
  static SupabaseClient? mockClient;

  static SupabaseClient get _client => mockClient ?? Supabase.instance.client;

  /// Dynamic personnel overrides mapping (date string -> personnel count).
  static Map<String, int> personnelOverrides = {};

  /// Resolve active personnel count for a specific date.
  static int getPersonnelForDate(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return personnelOverrides[dateStr] ?? 3; // Defaults to 3
  }

  /// Spa opening / closing hours.
  static const int openHour = 10; // 10 AM
  static const int closeHour = 18; // 6 PM

  // ─── Treatments ─────────────────────────────────────────────

  /// Fetch all treatments from Supabase.
  /// Falls back to local data if the request fails.
  static Future<List<SpaTreatment>> fetchTreatments() async {
    try {
      final response = await _client
          .from('treatments')
          .select()
          .order('id', ascending: true);
      return (response as List)
          .map((row) => SpaTreatment.fromJson(row))
          .toList();
    } catch (_) {
      return spaMenuFallback;
    }
  }

  // ─── Availability ───────────────────────────────────────────

  /// Returns confirmed bookings for a given [date].
  /// Tries calling the secure anonymized database RPC function first.
  /// Falls back to direct SELECT if RPC is not yet set up on the database.
  static Future<List<Map<String, dynamic>>> fetchBookingsForDate(
      DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final response = await _client
          .rpc('get_anonymized_bookings', params: {'target_date': dateStr});
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await _client
            .from('bookings')
            .select()
            .eq('booking_date', dateStr)
            .eq('status', 'confirmed');
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        return [];
      }
    }
  }

  /// Generate all possible 30-min start times between open and close.
  static List<String> allTimeSlots() {
    final slots = <String>[];
    for (int h = openHour; h < closeHour; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00:00');
      slots.add('${h.toString().padLeft(2, '0')}:30:00');
    }
    return slots;
  }

  /// Returns available start times for a given [date] and [durationMinutes].
  /// A slot is available if there is at least one room free for the full
  /// duration of the treatment.
  static Future<List<String>> availableSlots(
      DateTime date, int durationMinutes) async {
    final bookedRows = await fetchBookingsForDate(date);
    final allSlots = allTimeSlots();
    final available = <String>[];

    for (final slot in allSlots) {
      // Check that the treatment fits before closing time
      final startParts = slot.split(':');
      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = startMinutes + durationMinutes;
      if (endMinutes > closeHour * 60) continue; // treatment runs past close

      // Count how many rooms are booked during this slot's time range
      int roomsBooked = 0;
      for (final booking in bookedRows) {
        final bStart = _timeToMinutes(booking['start_time'] as String);
        final bEnd = _timeToMinutes(booking['end_time'] as String);
        // Overlap check: the new slot [startMinutes, endMinutes) overlaps
        // with existing [bStart, bEnd)
        if (startMinutes < bEnd && endMinutes > bStart) {
          roomsBooked++;
        }
      }
      if (roomsBooked < getPersonnelForDate(date)) {
        available.add(slot);
      }
    }
    return available;
  }

  /// Find the first free room number for [date] at [startTime] with
  /// the given [durationMinutes].
  static Future<int> _findFreeRoom(
      DateTime date, String startTime, int durationMinutes) async {
    final bookedRows = await fetchBookingsForDate(date);
    final startMin = _timeToMinutes(startTime);
    final endMin = startMin + durationMinutes;

    final occupiedRooms = <int>{};
    for (final booking in bookedRows) {
      final bStart = _timeToMinutes(booking['start_time'] as String);
      final bEnd = _timeToMinutes(booking['end_time'] as String);
      if (startMin < bEnd && endMin > bStart) {
        occupiedRooms.add(booking['room_number'] as int);
      }
    }
    for (int room = 1; room <= getPersonnelForDate(date); room++) {
      if (!occupiedRooms.contains(room)) return room;
    }
    return 1; // fallback (shouldn't happen if availability was checked)
  }

  // ─── Create Booking ─────────────────────────────────────────

  /// Insert a new booking. Returns the created row or throws.
  static Future<Map<String, dynamic>> createBooking({
    required String customerName,
    required String customerEmail,
    required int treatmentId,
    required DateTime date,
    required String startTime,
    required int durationMinutes,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final startMin = _timeToMinutes(startTime);
    final endMin = startMin + durationMinutes;
    final endTime =
        '${(endMin ~/ 60).toString().padLeft(2, '0')}:${(endMin % 60).toString().padLeft(2, '0')}:00';

    final room = await _findFreeRoom(date, startTime, durationMinutes);

    final response = await _client.from('bookings').insert({
      'customer_name': customerName,
      'customer_email': customerEmail,
      'treatment_id': treatmentId,
      'booking_date': dateStr,
      'start_time': startTime,
      'end_time': endTime,
      'room_number': room,
      'status': 'confirmed',
    }).select().single();

    return response;
  }

  // ─── Admin Operations ───────────────────────────────────────

  /// Fetch all bookings from Supabase.
  static Future<List<Map<String, dynamic>>> fetchAllBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, treatments(title)')
          .order('booking_date', ascending: false)
          .order('start_time', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  /// Cancel a booking by ID.
  static Future<void> cancelBooking(int bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);
  }

  // ─── Authentication ─────────────────────────────────────────

  /// Check if the user is authenticated.
  static bool get isAuthenticated {
    try {
      return _client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  /// Sign in with email and password.
  static Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign out.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── Helpers ────────────────────────────────────────────────

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
