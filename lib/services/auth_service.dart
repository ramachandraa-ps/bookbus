import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
      } catch (firestoreError) {
        debugPrint('Firestore error during signup: $firestoreError');
        // Continue without Firestore write if it fails
        // This will allow authentication to work even if Firestore is not enabled
      }

      return userModel;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Try to get user data from Firestore
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        }
      } catch (firestoreError) {
        debugPrint('Firestore error during signin: $firestoreError');
        // Continue with basic user info if Firestore fails
      }

      // If Firestore fails or user doc doesn't exist, create a basic user model
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? email.split('@').first,
        email: email,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Try to get basic info from Auth
        final authUser = _auth.currentUser;
        if (authUser != null && authUser.uid == uid) {
          return UserModel(
            uid: authUser.uid,
            name: authUser.displayName ??
                authUser.email?.split('@').first ??
                'User',
            email: authUser.email ?? '',
            createdAt: DateTime.now(),
          );
        }
        return null;
      }

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching user data: $e');

      // If Firestore fails, try to return basic user info from Auth
      final authUser = _auth.currentUser;
      if (authUser != null && authUser.uid == uid) {
        return UserModel(
          uid: authUser.uid,
          name: authUser.displayName ??
              authUser.email?.split('@').first ??
              'User',
          email: authUser.email ?? '',
          createdAt: DateTime.now(),
        );
      }

      throw Exception('Error fetching user data: $e');
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(dynamic e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Incorrect password.');
        case 'email-already-in-use':
          return Exception('This email is already registered.');
        case 'weak-password':
          return Exception('Password is too weak.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        default:
          return Exception('Authentication error: ${e.message}');
      }
    }
    return Exception('Authentication error: $e');
  }
}
