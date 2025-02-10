import 'package:flutter/material.dart';
import 'package:snapscore_android/features/essay_results/services/essay_results_service.dart';
import 'package:snapscore_android/features/identification_results/screens/student_paper_screen.dart';
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
  final _essayService = EssayResultsService();

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
            .indexWhere((criteria) => criteria.criteriaId == criteriaId);
        if (criteriaIndex != -1) {
          _selectedQuestion.essayCriteriaResults[criteriaIndex] =
              EssayCriteriaResult(
            id: criteriaId,
            score: newScore.toInt(),
            criteriaId: _selectedQuestion
                .essayCriteriaResults[criteriaIndex].criteriaId,
            questionResultId: _selectedQuestion
                .essayCriteriaResults[criteriaIndex].questionResultId,
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

  Future<void> _deleteResult() async {
    try {
      final result = await _essayService.deleteEssayResult(widget.result.id);
      if (result) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting result: $e')),
      );
    }
  }

  Widget _buildCriteriaScoreField(EssayCriteriaResult criteria) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '${criteria.criteria?.criteria ?? "Unknown Criteria"} (${criteria.criteria?.maxScore ?? 0})',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.grey),
                  controller: TextEditingController(
                    text: criteria.score.toString(),
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
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total score from the actual score property
    int totalScore = widget.result.score;

    // Calculate max possible score by summing up max scores from criteria
    int maxPossibleScore = _selectedQuestion.essayCriteriaResults
        .fold(0, (sum, criteria) => sum + (criteria.criteria?.maxScore ?? 0));

    // Rest of the build method remains the same...

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Results',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: _deleteResult,
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Delete Results',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Section
                    _buildSectionHeader('Student', 'rubric_item'),
                    const SizedBox(height: 8),
                    _buildInfoContainer(widget.result.studentName),
                    const SizedBox(height: 24),

                    // Question Section
                    _buildSectionHeader('Question', 'rubric_item'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Colors.black.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<EssayQuestionResult>(
                        value: _selectedQuestion,
                        isExpanded: true,
                        underline: Container(),
                        items: widget.result.questionResults.map((question) {
                          return DropdownMenuItem(
                            value: question,
                            child: Text(
                              question.question.question,
                            ),
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
                    _buildSectionHeader('Answer', 'rubric_item'),
                    const SizedBox(height: 8),
                    _buildInfoContainer(_selectedQuestion.answer),
                    const SizedBox(height: 24),

                    // Results Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Results', 'rubric_item'),
                        Row(
                          children: [
                            Text(
                              'Total Score: ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$totalScore/$maxPossibleScore',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
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
                  ],
                ),
              ),
            ),
          ),
          if (widget.result.paperImage.isNotEmpty &&
              widget.result.paperImage != 'notfound.jpg')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.black.withOpacity(0.1)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentPaperScreen(
                            imageUrl: widget.result.paperImage),
                      ),
                    );
                  },
                  child: const Text(
                    'View Paper',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String iconName) {
    return Row(
      children: [
        Image.asset("assets/icons/$iconName.png"),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContainer(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
