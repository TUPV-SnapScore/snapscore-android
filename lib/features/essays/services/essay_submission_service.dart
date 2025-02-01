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
          'questionNumber': question.questionNumber,
          'questionText': question.questionText,
          'essayId': essayId,
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
          'criteriaNumber': criteria.criteriaNumber,
          'criteriaText': criteria.criteriaText,
          'maxScore': criteria.maxScore,
          'essayId': essayId,
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
      final response = await http.post(
        Uri.parse('$baseUrl/essay-assessment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': essayTitle,
          'userId': userId,
          'totalScore': criteria.fold(0.0, (sum, item) => sum + item.maxScore),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create essay: ${data['message']}');
      }

      final essayId = data['id'];

      // Create questions
      for (var question in questions) {
        await _createEssayQuestion(question: question, essayId: essayId);
      }

      // Create criteria
      for (var criterion in criteria) {
        await _createEssayCriteria(criteria: criterion, essayId: essayId);
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
    double? totalScore,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': essayTitle,
      };

      if (totalScore != null) {
        body['totalScore'] = totalScore;
      }

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
          'questionText': questionText,
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
          'criteriaText': criteriaText,
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
