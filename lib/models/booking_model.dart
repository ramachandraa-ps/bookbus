import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, cancelled }

class BookingModel {
  final String id;
  final String userId;
  final String service;
  final DateTime date;
  final String time;
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: id,
      userId: json['userId'] ?? '',
      service: json['service'] ?? '',
      date:
          json['date'] != null
              ? (json['date'] as Timestamp).toDate()
              : DateTime.now(),
      time: json['time'] ?? '',
      status: _parseStatus(json['status']),
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'service': service,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static BookingStatus _parseStatus(String? status) {
    if (status == 'confirmed') return BookingStatus.confirmed;
    if (status == 'cancelled') return BookingStatus.cancelled;
    return BookingStatus.pending;
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? service,
    DateTime? date,
    String? time,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
