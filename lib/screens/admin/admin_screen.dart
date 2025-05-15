import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../constants/routes.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../widgets/primary_button.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Notification functionality removed temporarily
  // final TextEditingController _notificationController = TextEditingController();

  @override
  void dispose() {
    // _notificationController.dispose();
    super.dispose();
  }

  Future<void> _updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.updateBookingStatus(bookingId, status);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking status updated to ${status.toString().split('.').last}',
        ),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppConstants.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.go(AppRoutes.home);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppConstants.secondaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage bookings and notifications',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs for All Bookings
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('All Bookings', style: AppConstants.subheadingStyle),
          ),

          // Bookings List
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: bookingProvider.getAllBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                  );
                }

                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return const Center(child: Text('No bookings available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booking ID and User ID
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Booking #${booking.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'User: ${booking.userId.substring(0, 8)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),

                            // Booking details
                            _buildDetailRow('Service', booking.service),
                            const SizedBox(height: 4),
                            _buildDetailRow(
                              'Date',
                              '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                            ),
                            const SizedBox(height: 4),
                            _buildDetailRow('Time', booking.time),
                            const SizedBox(height: 4),
                            _buildDetailRow(
                              'Status',
                              booking.status
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              textColor: _getStatusColor(booking.status),
                            ),
                            const SizedBox(height: 16),

                            // Status update buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (booking.status != BookingStatus.confirmed)
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateBookingStatus(
                                        booking.id,
                                        BookingStatus.confirmed,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppConstants.successColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Confirm'),
                                  ),
                                const SizedBox(width: 8),
                                if (booking.status != BookingStatus.cancelled)
                                  OutlinedButton(
                                    onPressed: () {
                                      _updateBookingStatus(
                                        booking.id,
                                        BookingStatus.cancelled,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppConstants.errorColor,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Send notification section - Removed temporarily
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications - Coming Soon',
                    style: AppConstants.subheadingStyle),
                const SizedBox(height: 8),
                const Text(
                  'Notification functionality will be added in a future update.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppConstants.successColor;
      case BookingStatus.cancelled:
        return AppConstants.errorColor;
      default:
        return AppConstants.accentColor;
    }
  }
}
