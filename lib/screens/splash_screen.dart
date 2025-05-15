import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Navigate after splash screen duration
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToNextScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Icon(
                Icons.directions_bus,
                size: 100,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: 24),
              
              // App Name
              Text(
                AppConstants.appName,
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 36,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'Book Your Ride Easily',
                style: AppConstants.subheadingStyle.copyWith(
                  color: AppConstants.secondaryColor,
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryColor,
                  ),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 