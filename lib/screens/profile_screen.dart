import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2; // Profile tab index

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate based on tab index
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.myBookings);
        break;
      case 2:
        // Already on profile
        break;
    }
  }

  Future<void> _showLogoutConfirmDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppConstants.secondaryColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(color: AppConstants.errorColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // If user is not authenticated, redirect to login
    if (!authProvider.isAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _showLogoutConfirmDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Profile picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 70,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User name
            Text(
              user?.name ?? 'User',
              style: AppConstants.headingStyle,
              textAlign: TextAlign.center,
            ),

            // User email
            Text(
              user?.email ?? 'email@example.com',
              style: AppConstants.captionStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Profile menu items
            _buildProfileMenuItem(
              icon: Icons.history,
              title: 'Booking History',
              onTap: () {
                context.go(AppRoutes.myBookings);
              },
            ),

            _buildProfileMenuItem(
              icon: Icons.payment,
              title: 'Payment Methods',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Payment methods will be implemented in future updates',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            _buildProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notification Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Notification settings will be implemented in future updates',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            _buildProfileMenuItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Help & Support will be implemented in future updates',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            _buildProfileMenuItem(
              icon: Icons.info,
              title: 'About App',
              onTap: () {
                _showAboutDialog();
              },
            ),

            const SizedBox(height: 40),

            // Logout button
            SizedBox(
              width: 200,
              child: PrimaryButton(
                text: 'Logout',
                onPressed: _showLogoutConfirmDialog,
                isLoading: authProvider.isLoading,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppConstants.primaryColor),
        title: Text(title, style: AppConstants.bodyStyle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'About ${AppConstants.appName}',
              style: AppConstants.subheadingStyle,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.directions_bus,
                    size: 60,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version: ${AppConstants.appVersion}',
                  style: AppConstants.bodyStyle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'BookBus is a bus booking application that helps you book bus tickets easily.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '© 2023 BookBus. All rights reserved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
    );
  }
}
