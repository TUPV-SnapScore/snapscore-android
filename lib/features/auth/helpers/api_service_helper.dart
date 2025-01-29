// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl;

  ApiService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> register(
      {required String email,
      required String userId,
      required String fullName}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'firebaseId': userId,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> googleSignIn(
      {required String email,
      required String fullName,
      required String userId}) async {
    try {
      final existingUser = await http.get(
        Uri.parse('$baseUrl/users/firebase/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (existingUser.statusCode == 200) {
        return jsonDecode(existingUser.body);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Google sign-in failed');
      }
    } catch (e) {
      throw Exception('Failed to register with Google: ${e.toString()}');
    }
  }
}
