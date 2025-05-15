import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;
  final NotificationService _notificationService;

  // State
  bool _isLoading = false;
  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  String? get error => _error;

  BookingProvider({
    required BookingService bookingService,
    required NotificationService notificationService,
  })  : _bookingService = bookingService,
        _notificationService = notificationService;

  // Create a new booking
  Future<bool> createBooking({
    required String userId,
    required String service,
    required DateTime date,
    required String time,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final booking = await _bookingService.createBooking(
        userId: userId,
        service: service,
        date: date,
        time: time,
      );

      _currentBooking = booking;

      // Show local notification
      await _notificationService.showBookingNotification(
        title: 'Booking Request Received',
        body:
            'Your booking request for $service on ${_formatDate(date)} at $time has been received.',
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

  // Load user's bookings
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingService.getUserBookings(userId);
  }

  // Get all bookings (for admin)
  Stream<List<BookingModel>> getAllBookings() {
    return _bookingService.getAllBookings();
  }

  // Set bookings list (called when listening to the stream)
  void setBookings(List<BookingModel> bookings) {
    _bookings = bookings;
    notifyListeners();
  }

  // Get booking by ID
  Future<void> getBookingById(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final booking = await _bookingService.getBookingById(bookingId);
      _currentBooking = booking;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _bookingService.updateBookingStatus(bookingId, status);

      // Update the current booking if it's the one being modified
      if (_currentBooking != null && _currentBooking!.id == bookingId) {
        _currentBooking = _currentBooking!.copyWith(status: status);
      }

      // Update the booking in the list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index >= 0) {
        _bookings[index] = _bookings[index].copyWith(status: status);
      }

      // Show notification
      final statusString =
          status == BookingStatus.confirmed ? 'confirmed' : 'cancelled';

      await _notificationService.showBookingNotification(
        title: 'Booking $statusString',
        body: 'Your booking has been $statusString.',
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

  // Clear current booking
  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Format date helper
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
