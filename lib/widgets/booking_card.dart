import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onViewDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    // Determine status color
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = AppConstants.successColor;
        break;
      case BookingStatus.cancelled:
        statusColor = AppConstants.errorColor;
        break;
      default:
        statusColor = AppConstants.accentColor;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Booking #${booking.id.substring(0, 8)}',
                    style: AppConstants.subheadingStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    booking.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Booking details
            _buildDetailRow(
              icon: Icons.directions_bus,
              title: 'Service',
              value: booking.service,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'Date',
              value: dateFormat.format(booking.date),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.access_time,
              title: 'Time',
              value: booking.time,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onViewDetails != null)
                  TextButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.secondaryColor,
                    ),
                  ),
                if (onCancel != null && booking.status == BookingStatus.pending)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.errorColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConstants.lightTextColor),
        const SizedBox(width: 8),
        Text(
          '$title:',
          style: AppConstants.captionStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppConstants.bodyStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
