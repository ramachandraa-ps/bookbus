import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  // Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Handle registration
  Future<void> _register() async {
    FocusScope.of(context).unfocus(); // Hide keyboard

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Use email as name for simplicity
      final name = _emailController.text.split('@').first;

      final success = await authProvider.signUp(
        name: name,
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
          // Background image
          Container(
            height: size.height * 0.4,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              image: const DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1000'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Clear error when navigating
                  authProvider.clearError();
                  context.go(AppRoutes.login);
                },
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.15),

                  // Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

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
                            const SizedBox(height: 16),

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
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Confirm your password',
                            obscureText: !_isConfirmPasswordVisible,
                            validator: _validateConfirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          PrimaryButton(
                            text: 'Register',
                            onPressed: _register,
                            isLoading: authProvider.isLoading,
                          ),

                          const SizedBox(height: 24),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: AppConstants.captionStyle,
                              ),
                              TextButton(
                                onPressed: () {
                                  // Clear error when navigating
                                  authProvider.clearError();
                                  context.go(AppRoutes.login);
                                },
                                child: Text(
                                  'Login',
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
