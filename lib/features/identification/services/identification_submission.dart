import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/identification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AssessmentService {
  final String baseUrl;

  AssessmentService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> _createIdentificationQuestions(
      {required IdentificationAnswer question,
      required String assessmentId}) async {
    try {
      final response =
          await http.post(Uri.parse('$baseUrl/identification-assessment'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'question': question.number,
                'answer': question.answer,
                'assessmentId': assessmentId
              }));

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating identification questions'
      };
    }
  }

  Future<Map<String, dynamic>> createAssessment({
    required String assessmentName,
    required List<IdentificationAnswer> questions,
  }) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/identification-assessment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': assessmentName}));

      final data = jsonDecode(response.body);

      if (!data) {
        throw Error();
      }

      final assessmentId = data['id'];
      for (var question in questions) {
        await _createIdentificationQuestions(
            question: question, assessmentId: assessmentId);
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to create assessment: $e'};
    }
  }
}
