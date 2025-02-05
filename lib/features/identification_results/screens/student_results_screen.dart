import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/identification_results_model.dart';
import '../services/student_result_service.dart';

class StudentResultScreen extends StatefulWidget {
  final IdentificationResultModel result;

  const StudentResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  final StudentIdentificationResultService _service =
      StudentIdentificationResultService();
  late List<QuestionResultModel> questionResults;

  @override
  void initState() {
    super.initState();
    questionResults = List.from(widget.result.questionResults);
  }

  Future<void> _updateQuestionResult(int index, bool isCorrect) async {
    try {
      final result = await _service.updateQuestionResult(
        questionResults[index].id,
        isCorrect,
      );

      if (result) {
        setState(() {
          questionResults[index] = QuestionResultModel(
            id: questionResults[index].id,
            answer: questionResults[index].answer,
            isCorrect: isCorrect,
            question: questionResults[index].question,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating result: $e')),
      );
    }
  }

  void _showAnswerOptions(int index) {
    final currentResult = questionResults[index];
    print(currentResult.answer);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            title: Text('Correct'),
          ),
          onTap: () => _updateQuestionResult(index, true),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            title: Text('Wrong'),
          ),
          onTap: () => _updateQuestionResult(index, false),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int correctAnswers =
        questionResults.where((result) => result.isCorrect).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Results',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Results',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Score: $correctAnswers/${questionResults.length}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questionResults.length,
              itemBuilder: (context, index) {
                final result = questionResults[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.edit_note,
                      color: AppColors.textSecondary,
                    ),
                    title: Row(
                      children: [
                        Text(
                          '${index + 1}. ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          result.answer,
                          style: TextStyle(
                            color: result.isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () => _showAnswerOptions(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // TODO: Implement view paper functionality
                },
                child: Text('View Paper'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
