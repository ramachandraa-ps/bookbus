import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  // State
  bool _isLoading = false;
  UserModel? _user;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    // Check current auth state when provider is created
    _checkCurrentUser();

    // Listen to auth state changes
    _authService.authStateChanges.listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
      } else {
        _fetchUserData(firebaseUser.uid);
      }
    });
  }

  // Check if user is already signed in
  Future<void> _checkCurrentUser() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser.uid);
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _authService.getUserData(uid);
      _user = userData;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      _user = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signIn(email: email, password: password);

      _user = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
