import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/essay_results_model.dart';

class EssayResultsService {
  final String baseUrl;

  EssayResultsService() : baseUrl = dotenv.get('API_URL');

  Future<List<EssayResult>> getResultsByAssessmentId(
      String assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/essay-results/assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch essay results');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => EssayResult.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error fetching essay results: $e');
    }
  }

  Future<void> updateCriteriaScore(String criteriaId, int newScore) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-results/criteria/$criteriaId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'score': newScore}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update criteria score');
      }
    } catch (e) {
      throw Exception('Error updating criteria score: $e');
    }
  }

  Future<bool> deleteEssayResult(String resultId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/essay-results/$resultId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete essay result');
      }

      return true;
    } catch (e) {
      throw Exception('Error deleting essay result: $e');
    }
  }

  Future<String> uploadPaper(String resultId, String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/essay-results/$resultId/upload-paper'),
      );

      request.files.add(await http.MultipartFile.fromPath('paper', filePath));

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to upload paper');
      }

      final responseData = await response.stream.bytesToString();
      return json.decode(responseData)['paperUrl'];
    } catch (e) {
      throw Exception('Error uploading paper: $e');
    }
  }
}
