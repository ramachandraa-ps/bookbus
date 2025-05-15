import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import '../widgets/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _currentIndex = 1; // My Bookings tab index

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    // Bookings are loaded through stream in booking provider
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate based on tab index
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        // Already on bookings
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
    }
  }

  Future<void> _showCancelConfirmationDialog(
    BuildContext context,
    BookingModel booking,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No, Keep Booking',
                style: TextStyle(color: AppConstants.secondaryColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes, Cancel Booking',
                style: TextStyle(color: AppConstants.errorColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelBooking(booking.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    await bookingProvider.updateBookingStatus(
      bookingId,
      BookingStatus.cancelled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    // If user is not authenticated, redirect to login
    if (!authProvider.isAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingProvider.getUserBookingsStream(authProvider.user!.uid),
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
          bookingProvider.setBookings(bookings);

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text('No bookings yet', style: AppConstants.subheadingStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Your bookings will appear here',
                    style: AppConstants.captionStyle,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingCard(
                  booking: booking,
                  onViewDetails: () {
                    // Could navigate to a booking details screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Viewing details for booking #${booking.id.substring(0, 8)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onCancel:
                      booking.status == BookingStatus.pending
                          ? () =>
                              _showCancelConfirmationDialog(context, booking)
                          : null,
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
