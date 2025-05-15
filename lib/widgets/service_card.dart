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

    // Get default image based on service ID's hash
    final imageUrl = service.imageUrl.isNotEmpty
        ? service.imageUrl
        : AssetUtils.getBusImage(service.id.hashCode);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Prevent overflow
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 250, // Fixed height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service image with price tag
              Stack(
                children: [
                  Hero(
                    tag: 'service-${service.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.directions_bus,
                                size: 50,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Price tag
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(16),
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

              // Service details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          service.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Available times
                      if (service.availableTimes.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: AppConstants.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Available Times:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 26, // Fixed height for times
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: service.availableTimes
                                    .take(3) // Show only first 3 times
                                    .map(
                                      (time) => Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppConstants.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: AppConstants.primaryColor
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppConstants.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Book Now button
              Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
