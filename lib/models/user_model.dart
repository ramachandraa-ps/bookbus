import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Timestamp {
  final int seconds;
  final int nanoseconds;

  Timestamp(this.seconds, this.nanoseconds);

  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static Timestamp fromDate(DateTime dateTime) {
    final milliseconds = dateTime.millisecondsSinceEpoch;
    final seconds = milliseconds ~/ 1000;
    final nanoseconds = (milliseconds % 1000) * 1000000;
    return Timestamp(seconds, nanoseconds);
  }
}
