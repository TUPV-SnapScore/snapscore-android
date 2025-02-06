import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/essay_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EssayService {
  final String baseUrl;

  EssayService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> _createEssayQuestion({
    required EssayQuestion question,
    required String essayId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/essay-questions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question.questionText,
          'assessmentId': essayId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating essay question: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _createEssayCriteria({
    required EssayCriteria criteria,
    required String essayId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/essay-criteria'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'criteria': criteria.criteriaText,
          'maxScore': criteria.maxScore,
          'essayQuestionId': essayId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed creating essay criteria: $e',
      };
    }
  }

  Future<Map<String, dynamic>> createEssay({
    required String essayTitle,
    required List<EssayQuestion> questions,
    required List<EssayCriteria> criteria,
    required String userId,
  }) async {
    try {
      // Create essay
      final response = await http.post(
        Uri.parse('$baseUrl/essay-assessment/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': essayTitle,
          'id': userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create essay: ${data['message']}');
      }

      final essayId = data['id'];

      // Create questions and associate criteria with each question
      for (var question in questions) {
        final questionResponse =
            await _createEssayQuestion(question: question, essayId: essayId);
        final questionId = questionResponse['id'];

        // Create criteria for this specific question
        for (var criterion in criteria) {
          await _createEssayCriteria(
              criteria: criterion,
              essayId: questionId // Associate with current question
              );
        }
      }

      return data;
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to create essay: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getEssay(String essayId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/essay-assessment/$essayId'),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to fetch essay: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateEssay({
    required String essayId,
    required String essayTitle,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': essayTitle,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/essay-assessment/$essayId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update essay: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateQuestion({
    required String questionId,
    required String questionText,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-questions/$questionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': questionText, // Changed from questionText to question
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update question: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateCriteria({
    required String criteriaId,
    required String criteriaText,
    required double maxScore,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-criteria/$criteriaId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'criteria': criteriaText, // Changed from criteriaText to criteria
          'maxScore': maxScore,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update criteria: $e',
      };
    }
  }
}
