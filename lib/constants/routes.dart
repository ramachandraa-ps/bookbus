import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/bookings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String payment = '/payment';
  static const String myBookings = '/bookings';
  static const String profile = '/profile';
  static const String admin = '/admin';

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      refreshListenable: authProvider,
      redirect: (context, state) {
        // Check if the user is authenticated
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == login ||
            state.matchedLocation == register ||
            state.matchedLocation == signup;
        final isSplash = state.matchedLocation == splash;

        // If the user is not authenticated, redirect to login
        if (!isAuthenticated && !isLoggingIn && !isSplash) {
          return login;
        }

        // If the user is authenticated and tries to access login/register, redirect to home
        if (isAuthenticated && isLoggingIn) {
          return home;
        }

        // No redirect needed
        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(path: login, builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(path: home, builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: booking,
          builder: (context, state) {
            final serviceId = state.uri.queryParameters['serviceId'];
            return BookingScreen(serviceId: serviceId);
          },
        ),
        GoRoute(
          path: payment,
          builder: (context, state) {
            final bookingId = state.uri.queryParameters['bookingId'];
            return PaymentScreen(bookingId: bookingId);
          },
        ),
        GoRoute(
          path: myBookings,
          builder: (context, state) => const BookingsScreen(),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(path: admin, builder: (context, state) => const AdminScreen()),
      ],
    );
  }
}
