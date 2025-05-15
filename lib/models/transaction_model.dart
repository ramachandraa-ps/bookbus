import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus { pending, success, failed }

class TransactionModel {
  final String id;
  final String userId;
  final String bookingId;
  final double amount;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? paymentId;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.paymentId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    // Handle different timestamp formats (Timestamp or milliseconds)
    DateTime getTimeFromJson(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return TransactionModel(
      id: id,
      userId: json['userId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      timestamp: getTimeFromJson(json['timestamp']),
      paymentId: json['paymentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bookingId': bookingId,
      'amount': amount,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'paymentId': paymentId,
    };
  }

  static TransactionStatus _parseStatus(String? status) {
    if (status == 'success') return TransactionStatus.success;
    if (status == 'failed') return TransactionStatus.failed;
    return TransactionStatus.pending;
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? bookingId,
    double? amount,
    TransactionStatus? status,
    DateTime? timestamp,
    String? paymentId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      paymentId: paymentId ?? this.paymentId,
    );
  }
}
