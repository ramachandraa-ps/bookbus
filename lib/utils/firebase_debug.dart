import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseDebug {
  /// Check and print Firebase connection status
  static Future<bool> checkFirebaseConnection() async {
    try {
      // Check Firebase Auth
      final auth = FirebaseAuth.instance;
      debugPrint('Firebase Auth instance created: ${auth.toString()}');

      // Check Firestore
      final firestore = FirebaseFirestore.instance;
      debugPrint('Firestore instance created: ${firestore.toString()}');

      // Try a simple Firestore operation
      try {
        final result =
            await firestore.collection('debug').doc('connection_test').set({
          'timestamp': FieldValue.serverTimestamp(),
          'client': 'Flutter app',
          'status': 'connection_test'
        });
        debugPrint('Firestore write successful');
        return true;
      } catch (e) {
        debugPrint('Firestore test operation failed: $e');
        // This is expected if Firestore isn't enabled yet, so don't throw
      }

      // If we got this far, at least Firebase Auth is working
      return true;
    } catch (e) {
      debugPrint('Firebase connection check failed: $e');
      return false;
    }
  }

  /// Create a test user account for debugging
  static Future<void> createTestUserIfNeeded() async {
    try {
      // Check if test account exists and create it if not
      const email = 'test@bookbus.app';
      const password = 'Test123!';

      try {
        // Try to sign in with test account
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('Test user exists, signed in successfully');
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          // Create test user if it doesn't exist
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          // Create user document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'uid': userCredential.user!.uid,
            'name': 'Test User',
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'isTestAccount': true
          });

          debugPrint('Test user created successfully');
        } else {
          debugPrint('Error with test user: $e');
        }
      }
    } catch (e) {
      debugPrint('Create test user failed: $e');
    }
  }
}
