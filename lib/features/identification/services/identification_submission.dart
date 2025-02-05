import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/identification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IdentificationService {
  final String baseUrl;

  IdentificationService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> _createIdentificationanswers(
      {required IdentificationAnswer answer,
      required String assessmentId}) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/identification-questions'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'question': answer.number.toString(),
                'correctAnswer': answer.answer,
                'assessmentId': assessmentId
              }));

      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating identification answers'
      };
    }
  }

  Future<Map<String, dynamic>> createAssessment(
      {required String assessmentName,
      required List<IdentificationAnswer> answers,
      required String userId}) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/identification-assessment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': assessmentName, 'userId': userId}));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create assessment: ${data['message']}');
      }

      print(data);

      final assessmentId = data['id'];
      for (var answer in answers) {
        await _createIdentificationanswers(
            answer: answer, assessmentId: assessmentId);
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to create assessment: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssessment(String assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/identification-assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response received');
        }

        final Map<String, dynamic> decodedData = json.decode(response.body);

        // Ensure identificationQuestions is not null
        if (decodedData['identificationQuestions'] == null) {
          decodedData['identificationQuestions'] = [];
        }

        return decodedData;
      } else {
        throw Exception('Failed to load assessment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assessment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions(String assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/identification-questions/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateAssessment({
    required String assessmentId,
    required String assessmentName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/identification-assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': assessmentName}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to update assessment: $e'};
    }
  }

  Future<Map<String, dynamic>> updateQuestion({
    required String questionId,
    required String answer,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/identification-questions/$questionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correctAnswer': answer,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to update question: $e'};
    }
  }
}
