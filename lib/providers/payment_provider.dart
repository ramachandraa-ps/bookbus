import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/payment_service.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService;
  final TransactionService _transactionService;
  final NotificationService _notificationService;

  // State
  bool _isLoading = false;
  List<TransactionModel> _transactions = [];
  TransactionModel? _currentTransaction;
  String? _error;
  bool _paymentSuccess = false;

  // Getters
  bool get isLoading => _isLoading;
  List<TransactionModel> get transactions => _transactions;
  TransactionModel? get currentTransaction => _currentTransaction;
  String? get error => _error;
  bool get paymentSuccess => _paymentSuccess;

  PaymentProvider({
    required PaymentService paymentService,
    required TransactionService transactionService,
    required NotificationService notificationService,
  }) : _paymentService = paymentService,
       _transactionService = transactionService,
       _notificationService = notificationService {
    // Set up payment callbacks
    _paymentService.onPaymentSuccess = _handlePaymentSuccess;
    _paymentService.onPaymentError = _handlePaymentError;
  }

  // Initialize a payment
  Future<bool> initiatePayment({
    required String userId,
    required String bookingId,
    required double amount,
    required String description,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _paymentSuccess = false;
      notifyListeners();

      // Create a transaction
      final transaction = await _transactionService.createTransaction(
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        status: TransactionStatus.pending,
      );

      _currentTransaction = transaction;

      // Start the mock payment process
      _paymentService.startPayment(
        transactionId: transaction.id,
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        description: description,
        name: name,
        email: email,
        phone: phone,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle successful payment
  void _handlePaymentSuccess(String transactionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get updated transaction
      final transaction = await _transactionService.getTransactionById(
        transactionId,
      );

      if (transaction != null) {
        _currentTransaction = transaction;
        _paymentSuccess = true;

        // Show notification
        await _notificationService.showPaymentNotification(
          title: 'Payment Successful',
          body:
              'Your payment of ₹${transaction.amount} has been processed successfully.',
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle payment error
  void _handlePaymentError(String errorMessage) async {
    _error = errorMessage;
    _paymentSuccess = false;

    try {
      // Show notification
      await _notificationService.showPaymentNotification(
        title: 'Payment Failed',
        body: 'Your payment could not be processed. Please try again.',
      );
    } finally {
      notifyListeners();
    }
  }

  // Get user transactions
  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _transactionService.getUserTransactions(userId);
  }

  // Set transactions (called when listening to the stream)
  void setTransactions(List<TransactionModel> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  // Get transaction by ID
  Future<void> getTransactionById(String transactionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final transaction = await _transactionService.getTransactionById(
        transactionId,
      );
      _currentTransaction = transaction;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current transaction
  void clearCurrentTransaction() {
    _currentTransaction = null;
    _paymentSuccess = false;
    notifyListeners();
  }

  // Reset payment state
  void resetPaymentState() {
    _paymentSuccess = false;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
