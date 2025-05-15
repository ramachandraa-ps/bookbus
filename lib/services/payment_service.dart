import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/booking_model.dart';
import './transaction_service.dart';
import './booking_service.dart';

class PaymentService {
  final TransactionService _transactionService;
  final BookingService _bookingService = BookingService();
  final Razorpay _razorpay = Razorpay();

  // Razorpay test credentials
  static const String _keyId = 'rzp_test_8DmfRFT3ZEhV7F';
  static const String _keySecret = 'UgQXen8uDJ3QeGVsLQBMM1ar';

  // Track current transaction details
  String? _currentTransactionId;
  String? _currentBookingId;

  // Callback functions for payment events
  Function(String)? onPaymentSuccess;
  Function(String)? onPaymentError;

  PaymentService({required TransactionService transactionService})
      : _transactionService = transactionService {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  // Start a payment with Razorpay
  Future<void> startPayment({
    required String transactionId,
    required String userId,
    required String bookingId,
    required double amount,
    required String description,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      // Store current transaction and booking IDs for reference in callbacks
      _currentTransactionId = transactionId;
      _currentBookingId = bookingId;

      // Create a pending transaction in Firestore
      final transaction = await _transactionService.createTransaction(
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        status: TransactionStatus.pending,
      );

      // Update the current transaction ID with the one from Firestore
      _currentTransactionId = transaction.id;

      // Convert amount to paise (Razorpay uses smallest currency unit)
      final amountInPaise = (amount * 100).toInt();

      // Configure payment options
      final options = {
        'key': _keyId,
        'amount': amountInPaise,
        'name': 'BookBus',
        'description': description,
        'prefill': {
          'contact': phone ?? '',
          'email': email,
          'name': name,
        },
        'theme': {
          'color': '#FB8C00',
        },
        'external': {
          'wallets': ['paytm']
        },
        'notes': {
          'transaction_id': transaction.id,
          'booking_id': bookingId,
          'user_id': userId,
        },
      };

      // Open Razorpay checkout
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting payment: $e');
      // Handle error
      if (onPaymentError != null) {
        onPaymentError!('Payment failed: $e');
      }
    }
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final transactionId = _currentTransactionId;
      final bookingId = _currentBookingId;

      if (transactionId == null) {
        throw Exception('Transaction ID not found');
      }

      // Update transaction to success in Firestore
      await _transactionService.updateTransactionStatus(
        transactionId: transactionId,
        status: TransactionStatus.success,
        paymentId: response.paymentId,
      );

      // Update booking status to confirmed if we have a booking ID
      if (bookingId != null) {
        try {
          await _bookingService.updateBookingStatus(
              bookingId, BookingStatus.confirmed);
          debugPrint('Booking $bookingId confirmed after successful payment');
        } catch (e) {
          debugPrint('Error updating booking status: $e');
        }
      }

      // Notify success
      if (onPaymentSuccess != null) {
        onPaymentSuccess!(transactionId);
      }
    } catch (e) {
      debugPrint('Error handling payment success: $e');
      if (onPaymentError != null) {
        onPaymentError!('Error processing successful payment: $e');
      }
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment error: ${response.message}');
    final transactionId = _currentTransactionId;

    if (transactionId != null) {
      // Update transaction status to failed
      _transactionService
          .updateTransactionStatus(
            transactionId: transactionId,
            status: TransactionStatus.failed,
          )
          .catchError(
              (e) => debugPrint('Error updating transaction status: $e'));
    }

    if (onPaymentError != null) {
      onPaymentError!('Payment failed: ${response.message ?? 'Unknown error'}');
    }
  }

  // Handle external wallet payment
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
    // This is usually handled in the same way as success in most apps
    // but we can customize if needed
  }
}
