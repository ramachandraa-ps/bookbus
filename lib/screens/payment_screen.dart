import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/primary_button.dart';

class PaymentScreen extends StatefulWidget {
  final String? bookingId;

  const PaymentScreen({super.key, this.bookingId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _paymentInitiated = false;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    if (widget.bookingId != null) {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      await bookingProvider.getBookingById(widget.bookingId!);
    }
  }

  // Process payment
  void _initiatePayment() {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final booking = bookingProvider.currentBooking;
    final user = authProvider.user;

    if (booking != null && user != null) {
      setState(() {
        _paymentInitiated = true;
      });

      // Get price based on booking service
      double price = _getPriceForService(booking.service);

      paymentProvider.initiatePayment(
        userId: user.uid,
        bookingId: booking.id,
        amount: price,
        description:
            'Payment for ${booking.service} on ${DateFormat('dd MMM yyyy').format(booking.date)} at ${booking.time}',
        name: user.name,
        email: user.email,
        // Use null for phone as it's not in UserModel
      );
    }
  }

  double _getPriceForService(String service) {
    // Return price based on service type
    switch (service.toLowerCase()) {
      case 'express bus':
        return 150.0;
      case 'local bus':
        return 50.0;
      case 'luxury bus':
        return 300.0;
      case 'night bus':
        return 500.0;
      default:
        return 150.0; // Default price
    }
  }

  void _handlePaymentSuccess() {
    // Navigate to my bookings screen
    context.go(AppRoutes.myBookings);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final booking = bookingProvider.currentBooking;

    // Show loading state while fetching booking details
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: AppConstants.primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Format the date
    final dateFormat = DateFormat('dd MMMM yyyy');
    final bookingDate = dateFormat.format(booking.date);

    // Get price based on booking service
    final price = _getPriceForService(booking.service);
    final baseFare = price * 0.8; // 80% of total is base fare
    final serviceCharge = price * 0.13; // 13% service charge
    final tax = price * 0.07; // 7% tax

    // Format currency
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
      locale: 'en_IN',
    );

    // If payment was successful, show success screen
    if (paymentProvider.paymentSuccess) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Icon(
                  Icons.check_circle,
                  color: AppConstants.successColor,
                  size: 100,
                ),
                const SizedBox(height: 32),

                // Success message
                Text(
                  'Payment Successful!',
                  style: AppConstants.headingStyle.copyWith(
                    color: AppConstants.successColor,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'Your booking has been confirmed',
                  style: AppConstants.bodyStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // View bookings button
                SizedBox(
                  width: 200,
                  child: PrimaryButton(
                    text: 'View My Bookings',
                    onPressed: _handlePaymentSuccess,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking details card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Details',
                      style: AppConstants.subheadingStyle,
                    ),
                    const Divider(height: 24),

                    // Booking ID
                    _buildDetailRow(
                      title: 'Booking ID',
                      value: booking.id.length > 8
                          ? booking.id.substring(0, 8)
                          : booking.id,
                    ),
                    const SizedBox(height: 8),

                    // Service
                    _buildDetailRow(title: 'Service', value: booking.service),
                    const SizedBox(height: 8),

                    // Date
                    _buildDetailRow(title: 'Date', value: bookingDate),
                    const SizedBox(height: 8),

                    // Time
                    _buildDetailRow(title: 'Time', value: booking.time),
                    const SizedBox(height: 8),

                    // Status
                    _buildDetailRow(
                      title: 'Status',
                      value: booking.status
                          .toString()
                          .split('.')
                          .last
                          .toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: AppConstants.subheadingStyle,
                    ),
                    const Divider(height: 24),

                    // Base fare
                    _buildDetailRow(
                      title: 'Base Fare',
                      value: currencyFormat.format(baseFare),
                      showDivider: true,
                    ),

                    // Service charge
                    _buildDetailRow(
                      title: 'Service Charge',
                      value: currencyFormat.format(serviceCharge),
                      showDivider: true,
                    ),

                    // Tax
                    _buildDetailRow(
                      title: 'Tax (GST)',
                      value: currencyFormat.format(tax),
                      showDivider: true,
                    ),

                    // Total amount
                    _buildDetailRow(
                      title: 'Total Amount',
                      value: currencyFormat.format(price),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Error message
            if (paymentProvider.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.errorColor, width: 1),
                ),
                child: Text(
                  paymentProvider.error!,
                  style: TextStyle(
                    color: AppConstants.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),

            if (paymentProvider.error != null) const SizedBox(height: 16),

            // Payment button
            PrimaryButton(
              text: 'Pay ${currencyFormat.format(price)}',
              onPressed: (_paymentInitiated || paymentProvider.isLoading)
                  ? null
                  : _initiatePayment,
              isLoading: paymentProvider.isLoading,
            ),

            const SizedBox(height: 12),

            // Cancel button
            Center(
              child: TextButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                child: Text(
                  'Cancel Payment',
                  style: TextStyle(color: AppConstants.errorColor),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment method info
            Center(
              child: Column(
                children: [
                  const Text(
                    'Test Payment System',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Razorpay Test Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can use any valid card number for testing',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Extra padding at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    bool showDivider = false,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: isBold
                    ? AppConstants.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : AppConstants.bodyStyle,
              ),
            ),
            const SizedBox(width: 8), // Add space between title and value
            Flexible(
              child: Text(
                value,
                style: isBold
                    ? AppConstants.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : AppConstants.bodyStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        if (showDivider) const Divider(height: 16),
      ],
    );
  }
}
