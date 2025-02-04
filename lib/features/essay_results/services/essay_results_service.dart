import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapscore_android/features/essay_results/models/essay_results_model.dart';

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
      print(data);
      return data.map((e) => EssayResult.fromJson(e)).toList();
    } catch (e) {
      print(e);
      throw Exception('Error fetching essay results: $e');
    }
  }
}
