import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/essay_model.dart';

class EssayService {
  Future<Map<String, dynamic>> _createEssayQuestion(
      {required EssayQuestion question, required String essayId}) async {
    try {
      final response = await http.post(
        Uri.parse('your-api-endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'questionNumber': question.questionNumber,
          'questionText': question.questionText,
          'essayId': essayId,
        }),
      );

      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating essay question',
      };
    }
  }

  Future<Map<String, dynamic>> _createEssayCriteria(
      {required EssayCriteria criteria, required String essayId}) async {
    try {
      final response = await http.post(
        Uri.parse('your-api-endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'criteriaNumber': criteria.criteriaNumber,
          'criteria': criteria.criteriaText,
          'maxScore': criteria.maxScore,
          'essayId': essayId,
        }),
      );

      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating essay criteria',
      };
    }
  }

  Future<Map<String, dynamic>> createEssay(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('your-api-endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create essay: ${responseData['message']}');
      }

      final essayId = responseData['id'];
      for (var question in data['questions']) {
        await _createEssayQuestion(question: question, essayId: essayId);
      }

      for (var criteria in data['criteria']) {
        await _createEssayCriteria(criteria: criteria, essayId: essayId);
      }

      return responseData;
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating essay',
      };
    }
  }
}
