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
      _isLoading = true;
      notifyListeners();

      if (user != null) {
        try {
          final userData =
              await _apiService.getUserByFirebaseId(userId: user.uid);
          setUserId(userData['id']);
        } catch (e) {
          print('Error fetching user data: $e');
          // If we can't get MongoDB user data, sign out
          await signOut();
        }
      } else {
        _userId = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null) {
        _user = credential.user;
        notifyListeners();
      }
      return credential;
    } catch (e) {
      print("Error in Google Sign In: $e");
      await signOut(); // Ensure we clean up if there's an error
      return null;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _userId = null;

    _isLoading = false;
    notifyListeners();
  }

  // Listen if user is null or user.uid is null then redirect to unauthenticatedRoute
  // else if user is authenticated then redirect to authenticatedRoute
  // else show CircularProgressIndicator

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _authService.signInWithEmailPassword(email, password);
  }

  Future<void> sendEmailResetPassword(String email) async {
    await _authService.sendEmailResetPassword(email);
  }

  Future<UserCredential> registerWithEmailPassword(
      String email, String password, String name) async {
    return await _authService.registerWithEmailPassword(email, password, name);
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
