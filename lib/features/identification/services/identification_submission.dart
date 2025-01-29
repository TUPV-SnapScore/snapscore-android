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
          await http.post(Uri.parse('$baseUrl/identification-assessment'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'question': answer.number,
                'correctAnswer': answer.answer,
                'assessmentId': assessmentId
              }));

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
}
