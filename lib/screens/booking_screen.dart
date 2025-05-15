import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';

class BookingScreen extends StatefulWidget {
  final String? serviceId;

  const BookingScreen({
    super.key,
    this.serviceId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  
  @override
  void initState() {
    super.initState();
    // Select the service if ID is provided
    if (widget.serviceId != null) {
      // Use a post-frame callback to ensure the context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
        serviceProvider.selectService(widget.serviceId!);
      });
    }
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppConstants.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Reset time selection when date changes
        _selectedTime = null;
      });
    }
  }

  // Validate that a time is selected
  String? _validateTime(String? value) {
    if (_selectedTime == null) {
      return 'Please select a time slot';
    }
    return null;
  }

  // Handle booking submission
  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      final service = serviceProvider.selectedService;
      
      if (service != null && authProvider.user != null) {
        final success = await bookingProvider.createBooking(
          userId: authProvider.user!.uid,
          service: service.name,
          date: _selectedDate,
          time: _selectedTime!,
        );
        
        if (success && mounted) {
          // Navigate to payment screen with the booking ID
          final bookingId = bookingProvider.currentBooking?.id;
          if (bookingId != null) {
            context.go('${AppRoutes.payment}?bookingId=$bookingId');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final selectedService = serviceProvider.selectedService;
    final dateFormat = DateFormat('dd MMMM yyyy');
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Book Your Ride'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: selectedService == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppConstants.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Details Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service heading
                            Text(
                              'Service Details',
                              style: AppConstants.subheadingStyle,
                            ),
                            const Divider(height: 24),
                            
                            // Service name
                            _buildDetailRow(
                              icon: Icons.directions_bus,
                              title: 'Service',
                              value: selectedService.name,
                            ),
                            const SizedBox(height: 8),
                            
                            // Service description
                            _buildDetailRow(
                              icon: Icons.info_outline,
                              title: 'Description',
                              value: selectedService.description,
                            ),
                            const SizedBox(height: 8),
                            
                            // Price
                            _buildDetailRow(
                              icon: Icons.currency_rupee,
                              title: 'Price',
                              value: '₹${selectedService.price.toInt()}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Booking details section
                    Text(
                      'Booking Details',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Picker
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[400]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppConstants.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Date: ${dateFormat.format(_selectedDate)}',
                                style: AppConstants.bodyStyle,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Time slots
                    Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Error message if no time selected
                    if (_formKey.currentState?.validate() == false && _selectedTime == null)
                      Text(
                        'Please select a time slot',
                        style: TextStyle(
                          color: AppConstants.errorColor,
                          fontSize: 12,
                        ),
                      ),
                    
                    // Time slots grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedService.availableTimes.map((time) {
                        final isSelected = _selectedTime == time;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppConstants.primaryColor
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.grey[400]!),
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Error message
                    if (bookingProvider.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bookingProvider.error!,
                          style: TextStyle(
                            color: AppConstants.errorColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Submit button
                    PrimaryButton(
                      text: 'Proceed to Payment',
                      onPressed: _submitBooking,
                      isLoading: bookingProvider.isLoading,
                    ),
                  ],
                ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppConstants.lightTextColor,
        ),
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
          ),
        ),
      ],
    );
  }
}