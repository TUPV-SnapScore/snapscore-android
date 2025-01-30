import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _userId; // MongoDB user ID
  bool _isLoading = true;

  AuthProvider() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

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
    _userId = null; // Clear MongoDB user ID on sign out
    notifyListeners();
  }

  Future<void> refreshAuthState() async {
    _isLoading = true;
    notifyListeners();

    _user = FirebaseAuth.instance.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  // New method to set MongoDB user ID
  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  User? get user => _user;
  String? get userId => _userId; // Getter for MongoDB user ID
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
}
