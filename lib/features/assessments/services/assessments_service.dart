import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapscore_android/features/assessments/models/assessment_model.dart';

class AssessmentsService {
  final String baseUrl;

  AssessmentsService() : baseUrl = dotenv.get('API_URL');

  Future<List<EssayAssessment>> getEssayAssessments(String userId) async {
    try {
      print('Fetching essay assessments $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/essay-assessment/user-essay/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => EssayAssessment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load essay assessments');
      }
    } catch (e) {
      throw Exception('Error fetching essay assessments: $e');
    }
  }

  Future<List<IdentificationAssessment>> getIdentificationAssessments(
      String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/identification-assessment/user-identification/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decodedData = json.decode(response.body);

        // Handle both single object and array responses
        if (decodedData == null) {
          return [];
        } else if (decodedData is List) {
          return decodedData
              .map((json) => IdentificationAssessment.fromJson(json))
              .toList();
        } else if (decodedData is Map<String, dynamic>) {
          return [IdentificationAssessment.fromJson(decodedData)];
        }

        return [];
      } else {
        throw Exception(
            'Failed to load identification assessments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching identification assessments: $e');
    }
  }
}
