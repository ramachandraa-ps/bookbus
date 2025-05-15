import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking
  Future<BookingModel> createBooking({
    required String userId,
    required String service,
    required DateTime date,
    required String time,
  }) async {
    try {
      final bookingData = {
        'userId': userId,
        'service': service,
        'date': Timestamp.fromDate(date),
        'time': time,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      final docRef = await _firestore.collection('bookings').add(bookingData);
      debugPrint('Created new booking with ID: ${docRef.id}');

      return BookingModel(
        id: docRef.id,
        userId: userId,
        service: service,
        date: date,
        time: time,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error creating booking: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get all bookings for a user
  Stream<List<BookingModel>> getUserBookings(String userId) {
    debugPrint('Getting bookings for user: $userId');
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('Received ${snapshot.docs.length} bookings from Firestore');
      return snapshot.docs.map((doc) {
        try {
          return BookingModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        } catch (e) {
          debugPrint('Error parsing booking document ${doc.id}: $e');
          // Return a placeholder booking on error to avoid breaking the stream
          return BookingModel(
            id: doc.id,
            userId: userId,
            service: 'Error loading service',
            date: DateTime.now(),
            time: '00:00',
            status: BookingStatus.pending,
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    });
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      debugPrint('Getting booking by ID: $bookingId');
      final doc = await _firestore.collection('bookings').doc(bookingId).get();

      if (!doc.exists) {
        debugPrint('Booking not found: $bookingId');
        return null;
      }

      return BookingModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('Error getting booking by ID: $e');
      throw Exception('Failed to get booking: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      debugPrint(
          'Updating booking status: $bookingId to ${status.toString().split('.').last}');
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
      });
      debugPrint('Booking status updated successfully');
    } catch (e) {
      debugPrint('Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Get all bookings (for admin)
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return BookingModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        } catch (e) {
          debugPrint('Error parsing booking document ${doc.id}: $e');
          // Return a placeholder booking on error
          return BookingModel(
            id: doc.id,
            userId: 'error',
            service: 'Error loading service',
            date: DateTime.now(),
            time: '00:00',
            status: BookingStatus.pending,
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    });
  }
}
