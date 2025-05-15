import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new transaction
  Future<TransactionModel> createTransaction({
    required String userId,
    required String bookingId,
    required double amount,
    TransactionStatus status = TransactionStatus.pending,
    String? paymentId,
  }) async {
    try {
      final transactionData = {
        'userId': userId,
        'bookingId': bookingId,
        'amount': amount,
        'status': status.toString().split('.').last,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'paymentId': paymentId,
      };

      final docRef =
          await _firestore.collection('transactions').add(transactionData);

      return TransactionModel(
        id: docRef.id,
        userId: userId,
        bookingId: bookingId,
        amount: amount,
        status: status,
        timestamp: DateTime.now(),
        paymentId: paymentId,
      );
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Update transaction status
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? paymentId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
      };

      if (paymentId != null) {
        updateData['paymentId'] = paymentId;
      }

      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update transaction status: $e');
    }
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final doc =
          await _firestore.collection('transactions').doc(transactionId).get();

      if (!doc.exists) {
        return null;
      }

      return TransactionModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  // Get all transactions for a user
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Get all transactions for a booking
  Future<List<TransactionModel>> getBookingTransactions(
    String bookingId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return TransactionModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get booking transactions: $e');
    }
  }
}
