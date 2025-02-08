import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/essay_results_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class EssayStudentResultScreen extends StatefulWidget {
  final EssayResult result;

  const EssayStudentResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<EssayStudentResultScreen> createState() =>
      _EssayStudentResultScreenState();
}

class _EssayStudentResultScreenState extends State<EssayStudentResultScreen> {
  late EssayQuestionResult _selectedQuestion;
  final String baseUrl = dotenv.get('API_URL');
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedQuestion = widget.result.questionResults.first;
  }

  Future<void> _updateCriteriaScore(String criteriaId, double newScore) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-results/criteria/$criteriaId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'score': newScore}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update criteria score');
      }

      // Update local state
      setState(() {
        final criteriaIndex = _selectedQuestion.essayCriteriaResults
            .indexWhere((criteria) => criteria.id == criteriaId);
        if (criteriaIndex != -1) {
          _selectedQuestion.essayCriteriaResults[criteriaIndex] =
              EssayCriteriaResult(
            id: criteriaId,
            score: newScore.toInt(),
            criteriaId: _selectedQuestion
                .essayCriteriaResults[criteriaIndex].criteriaId,
            questionResultId: _selectedQuestion
                .essayCriteriaResults[criteriaIndex].questionResultId,
            criteria:
                _selectedQuestion.essayCriteriaResults[criteriaIndex].criteria,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating score: $e')),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildCriteriaScoreField(EssayCriteriaResult criteria) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '${criteria.criteria.criteria} (${criteria.criteria.maxScore.toInt()})',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Score:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: criteria.score.toStringAsFixed(0),
            ),
            enabled: !_isUpdating,
            onSubmitted: (value) {
              final newScore = double.tryParse(value);
              if (newScore != null) {
                _updateCriteriaScore(criteria.id, newScore);
              }
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalScore = _selectedQuestion.essayCriteriaResults
        .fold(0, (sum, criteria) => sum + criteria.score);
    double maxScore = _selectedQuestion.essayCriteriaResults
        .fold(0, (sum, criteria) => sum + criteria.criteria.maxScore);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Results',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Section
              Row(
                children: [
                  Icon(Icons.person, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Student',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.result.studentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Question Dropdown
              Row(
                children: [
                  Icon(Icons.question_answer, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Question',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<EssayQuestionResult>(
                  value: _selectedQuestion,
                  isExpanded: true,
                  underline: Container(),
                  items: widget.result.questionResults.map((question) {
                    return DropdownMenuItem(
                      value: question,
                      child: Text(question.question.question),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedQuestion = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Answer Section
              Row(
                children: [
                  Icon(Icons.edit_note, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Answer',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_selectedQuestion.answer),
              ),
              const SizedBox(height: 24),

              // Results Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assessment, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Results',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Total Score: ${totalScore.toInt()}/${maxScore.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Criteria Scores
              ...(_selectedQuestion.essayCriteriaResults.map((criteria) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildCriteriaScoreField(criteria),
                );
              })),

              const SizedBox(height: 24),

              // View Paper Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement view paper functionality
                  },
                  child: const Text('View Paper'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
