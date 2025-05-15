import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // App configuration
  static const String appName = 'BookBus';
  static const String appVersion = '1.0.0';

  // API Keys (replace with your actual keys)
  static const String razorpayTestKey = 'rzp_test_YOUR_KEY_HERE';

  // Colors
  static const Color primaryColor = Color(0xFFFF7043); // Orange
  static const Color secondaryColor = Color(0xFF344955); // Dark Blue-Grey
  static const Color accentColor = Color(0xFFF9AA33); // Yellow
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textColor = Color(0xFF263238); // Almost Black
  static const Color lightTextColor = Color(0xFF78909C); // Light Blue-Grey
  static const Color errorColor = Color(0xFFB00020); // Red
  static const Color successColor = Color(0xFF4CAF50); // Green

  // Text Styles
  static final TextStyle headingStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final TextStyle subheadingStyle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static final TextStyle bodyStyle = GoogleFonts.poppins(
    fontSize: 16,
    color: textColor,
  );

  static final TextStyle captionStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: lightTextColor,
  );

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: captionStyle.copyWith(color: lightTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(vertical: 8.0);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 800);
}
