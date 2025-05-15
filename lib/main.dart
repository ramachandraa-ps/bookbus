import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'constants/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/service_provider.dart';
import 'providers/payment_provider.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/service_service.dart';
import 'services/payment_service.dart';
import 'services/transaction_service.dart';
import 'services/notification_service.dart';
import 'constants/app_constants.dart';
import 'utils/firebase_debug.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with explicit wait
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Check Firebase connection and debug
    final isConnected = await FirebaseDebug.checkFirebaseConnection();
    if (isConnected) {
      print('Firebase services connected successfully');
      // Create a test user for debugging
      await FirebaseDebug.createTestUserIfNeeded();
    } else {
      print('WARNING: Firebase services not fully connected');
    }
  } catch (error) {
    print('Failed to initialize Firebase: $error');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<BookingService>(create: (_) => BookingService()),
        Provider<ServiceService>(create: (_) => ServiceService()),
        Provider<TransactionService>(create: (_) => TransactionService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        // Providers that depend on services
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) =>
              AuthProvider(authService: context.read<AuthService>()),
          update: (context, authService, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<ServiceService, AuthProvider,
            ServiceProvider>(
          create: (context) => ServiceProvider(
            serviceService: context.read<ServiceService>(),
          ),
          update: (context, serviceService, authProvider, previous) =>
              previous!,
        ),
        ChangeNotifierProxyProvider2<BookingService, NotificationService,
            BookingProvider>(
          create: (context) => BookingProvider(
            bookingService: context.read<BookingService>(),
            notificationService: context.read<NotificationService>(),
          ),
          update: (context, bookingService, notificationService, previous) =>
              previous!,
        ),
        ProxyProvider<TransactionService, PaymentService>(
          create: (context) => PaymentService(
            transactionService: context.read<TransactionService>(),
          ),
          update: (context, transactionService, previous) => previous!,
        ),
        ChangeNotifierProxyProvider3<PaymentService, TransactionService,
            NotificationService, PaymentProvider>(
          create: (context) => PaymentProvider(
            paymentService: context.read<PaymentService>(),
            transactionService: context.read<TransactionService>(),
            notificationService: context.read<NotificationService>(),
          ),
          update: (
            context,
            paymentService,
            transactionService,
            notificationService,
            previous,
          ) =>
              previous!,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppConstants.primaryColor,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                primary: AppConstants.primaryColor,
                secondary: AppConstants.secondaryColor,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(),
              useMaterial3: true,
            ),
            routerConfig: AppRoutes.router(authProvider),
          );
        },
      ),
    );
  }
}
