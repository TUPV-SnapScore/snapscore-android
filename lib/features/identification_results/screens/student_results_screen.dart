import 'package:flutter/material.dart';
import 'package:snapscore_android/features/identification_results/screens/student_paper_screen.dart';
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
    questionResults = List.from(widget.result.questionResults ?? []);
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
          'SnapScore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Results',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Image.asset("assets/icons/rubric_item.png"),
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
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.result.studentName,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset("assets/icons/rubric_item.png"),
                    const SizedBox(width: 8),
                    Text(
                      'Results',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total Score: ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$correctAnswers/${questionResults.length}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/icons/rubric_item.png"),
                        const SizedBox(width: 12),
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      result.answer,
                      style: TextStyle(
                        fontSize: 18,
                        color: result.isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_horiz),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return StudentPaperScreen(
                      imageUrl: widget.result.paperImage,
                    );
                  }));
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
