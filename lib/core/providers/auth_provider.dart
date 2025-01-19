import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((User? user) {
      print("Auth state changed: ${user?.email}"); // Add this for debugging
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }
  // Add these methods to expose authentication functionality
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _authService.signInWithEmailPassword(email, password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<UserCredential> registerWithEmailPassword(
      String email, String password, String name) async {
    return await _authService.registerWithEmailPassword(email, password, name);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
}
