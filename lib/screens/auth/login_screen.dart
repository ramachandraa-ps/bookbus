import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Handle login
  Future<void> _login() async {
    FocusScope.of(context).unfocus(); // Hide keyboard

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to home screen
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Background image with gradient
          Container(
            height: size.height * 0.5,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              image: const DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?q=80&w=1000'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),

          // App logo and title
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.directions_bus_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Login form
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.35),

                  // Form Card
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Error message
                          if (authProvider.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppConstants.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppConstants.errorColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(
                                  color: AppConstants.errorColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          if (authProvider.error != null)
                            const SizedBox(height: 20),

                          // Email Field
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: !_isPasswordVisible,
                            validator: _validatePassword,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          PrimaryButton(
                            text: 'Login',
                            onPressed: _login,
                            isLoading: authProvider.isLoading,
                          ),
                          const SizedBox(height: 24),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: AppConstants.captionStyle,
                              ),
                              TextButton(
                                onPressed: () {
                                  // Clear error when navigating
                                  authProvider.clearError();
                                  context.go(AppRoutes.register);
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
