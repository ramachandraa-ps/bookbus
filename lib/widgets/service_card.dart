import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_model.dart';
import '../utils/asset_utils.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Calculate a price string that includes currency symbol
    final priceText = '₹${service.price.toInt()}';

    // Get image based on service type
    final imageUrl = service.imageUrl.isNotEmpty
        ? service.imageUrl
        : AssetUtils.getBusImageByType(service.name);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // Remove default margin to save space
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Prevent overflow
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important to prevent expansion
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top part: Image and price tag
            Stack(
              children: [
                // Image
                Image.network(
                  imageUrl,
                  height: 100, // Slightly reduced height
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: AppConstants.primaryColor,
                      ),
                    );
                  },
                ),

                // Price tag
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      priceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom part: Content with constrained height
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Important to prevent expansion
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bus type
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2), // Reduced spacing

                  // Times section with better layout
                  if (service.availableTimes.isNotEmpty)
                    _buildAvailableTimes(service.availableTimes),

                  // Book Now button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4), // Reduced margin
                    height: 26, // Slightly reduced height
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTimes(List<String> times) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Important to prevent expansion
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Times header with smaller height
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 10, // Smaller icon
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 2), // Reduced spacing
            const Text(
              'Available Times:',
              style: TextStyle(
                fontSize: 9, // Smaller text
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        // Times chips with more compact layout
        Wrap(
          spacing: 4,
          runSpacing: 2, // Reduced spacing
          children: times.take(3).map((time) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4, // Reduced padding
                vertical: 1, // Reduced padding
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 9, // Smaller text
                  color: AppConstants.primaryColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
