import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/spa_theme.dart';
import '../services/supabase_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _personnelCount = 3;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBookings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _personnelCount = prefs.getInt('total_rooms') ?? 3;
    });
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final bookings = await SupabaseService.fetchAllBookings();
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  Future<void> _updatePersonnelCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_rooms', count);
    SupabaseService.totalRooms = count;
    setState(() {
      _personnelCount = count;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Personnel count updated to $count')),
      );
    }
  }

  Future<void> _cancelBooking(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await SupabaseService.cancelBooking(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
        }
        _loadBookings();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: SpaColors.terracotta,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: SpaColors.sand,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Config Section
            Card(
              color: SpaColors.warmBeige,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: SpaColors.terracotta.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Personnel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SpaColors.deepBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Limits maximum parallel bookings per slot',
                            style: TextStyle(
                              fontSize: 12,
                              color: SpaColors.deepBrown.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: _personnelCount,
                      dropdownColor: SpaColors.warmBeige,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SpaColors.terracotta,
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 Person')),
                        DropdownMenuItem(value: 2, child: Text('2 People')),
                        DropdownMenuItem(value: 3, child: Text('3 People')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _updatePersonnelCount(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header for Bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bookings List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: SpaColors.terracotta,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: SpaColors.terracotta),
                  onPressed: _loadBookings,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Bookings List Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bookings.isEmpty
                      ? Center(
                          child: Text(
                            'No bookings found',
                            style: TextStyle(
                              color: SpaColors.deepBrown.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final booking = _bookings[index];
                            final id = booking['id'] as int;
                            final name = booking['customer_name'] as String;
                            final email = booking['customer_email'] as String;
                            final date = booking['booking_date'] as String;
                            final time = booking['start_time'] as String;
                            final room = booking['room_number'] as int;
                            final status = booking['status'] as String;
                            final isCancelled = status == 'cancelled';

                            return Card(
                              color: isCancelled
                                  ? Colors.red[50]
                                  : Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isCancelled
                                      ? Colors.red[100]!
                                      : SpaColors.terracotta
                                          .withValues(alpha: 0.15),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isCancelled
                                              ? Colors.red[700]
                                              : SpaColors.deepBrown,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCancelled
                                            ? Colors.red[100]
                                            : Colors.green[100],
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isCancelled
                                              ? Colors.red[700]
                                              : Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Email: $email',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: SpaColors.deepBrown
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: SpaColors.terracotta,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          date,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: SpaColors.terracotta,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatTime(time),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Room/Personnel Assigned: $room',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: SpaColors.deepBrown
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: !isCancelled
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _cancelBooking(id),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h12:$minute $period';
  }
}
