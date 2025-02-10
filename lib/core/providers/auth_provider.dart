import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapscore_android/features/auth/helpers/api_service_helper.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  User? _user;
  String? _userId; // MongoDB user ID
  bool _isLoading = true;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null && _userId == null) {
        // If we have a Firebase user but no MongoDB userId, fetch it
        try {
          final userData =
              await _apiService.getUserByFirebaseId(userId: user.uid);
          setUserId(userData['id']);
        } catch (e) {
          print('Error fetching user data: $e');
        }
      }
      _isLoading = false;
      print("User id: $_userId");
      notifyListeners();
    });
  }

  // Load userId from secure storage

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _authService.signInWithEmailPassword(email, password);
  }

  Future<void> sendEmailResetPassword(String email) async {
    await _authService.sendEmailResetPassword(email);
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

  // Set MongoDB user ID and save it to secure storage
  void setUserId(String id) async {
    _userId = id;
    notifyListeners();
  }

  User? get user => _user;
  String? get userId => _userId; // Getter for MongoDB user ID
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
}
