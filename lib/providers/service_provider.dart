import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceService _serviceService;

  // State
  bool _isLoading = false;
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<ServiceModel> get services => _services;
  ServiceModel? get selectedService => _selectedService;
  String? get error => _error;

  ServiceProvider({required ServiceService serviceService})
    : _serviceService = serviceService {
    // Initialize by adding sample services if needed
    _initializeServices();
  }

  // Initialize services
  Future<void> _initializeServices() async {
    try {
      await _serviceService.addSampleServices();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get services stream
  Stream<List<ServiceModel>> getServicesStream() {
    return _serviceService.getServices();
  }

  // Set services (called when listening to the stream)
  void setServices(List<ServiceModel> services) {
    _services = services;
    notifyListeners();
  }

  // Select a service
  void selectService(String serviceId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final service = await _serviceService.getServiceById(serviceId);
      _selectedService = service;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select service from the list without API call
  void selectServiceFromList(String serviceId) {
    final service = _services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => services.first,
    );

    _selectedService = service;
    notifyListeners();
  }

  // Clear selected service
  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
