import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available services
  Stream<List<ServiceModel>> getServices() {
    return _firestore.collection('services').orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();

      if (!doc.exists) {
        return null;
      }

      return ServiceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  // Add sample services (to be used for initialization)
  Future<void> addSampleServices() async {
    try {
      // Check if services collection is empty
      final querySnapshot =
          await _firestore.collection('services').limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Services already exist, no need to add samples
        return;
      }

      // Add sample services
      final sampleServices = [
        {
          'name': 'Express Bus',
          'description': 'Fast bus service with limited stops',
          'price': 150.0,
          'imageUrl': 'https://example.com/express-bus.jpg',
          'availableTimes': [
            '08:00',
            '10:00',
            '12:00',
            '14:00',
            '16:00',
            '18:00',
          ],
        },
        {
          'name': 'Luxury Bus',
          'description': 'Premium service with comfortable seats and amenities',
          'price': 300.0,
          'imageUrl': 'https://example.com/luxury-bus.jpg',
          'availableTimes': ['09:00', '12:00', '15:00', '18:00', '21:00'],
        },
        {
          'name': 'Night Bus',
          'description': 'Overnight travel with sleeping facilities',
          'price': 500.0,
          'imageUrl': 'https://example.com/night-bus.jpg',
          'availableTimes': ['20:00', '21:00', '22:00', '23:00', '00:00'],
        },
        {
          'name': 'Local Bus',
          'description': 'Regular service with all stops',
          'price': 50.0,
          'imageUrl': 'https://example.com/local-bus.jpg',
          'availableTimes': [
            '07:00',
            '08:00',
            '09:00',
            '10:00',
            '11:00',
            '12:00',
            '13:00',
            '14:00',
            '15:00',
            '16:00',
            '17:00',
            '18:00',
          ],
        },
      ];

      // Add services to Firestore
      for (final service in sampleServices) {
        await _firestore.collection('services').add(service);
      }
    } catch (e) {
      throw Exception('Failed to add sample services: $e');
    }
  }
}
