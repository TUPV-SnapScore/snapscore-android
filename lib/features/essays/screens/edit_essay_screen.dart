import 'package:flutter/material.dart';
import 'package:snapscore_android/core/themes/colors.dart';
import 'package:snapscore_android/features/camera/widgets/camera.dart';
import 'package:snapscore_android/features/essay_results/screens/essay_results_screen.dart';
import 'package:snapscore_android/features/essays/models/essay_model.dart';
import 'package:snapscore_android/features/essays/services/essay_submission_service.dart';
import 'package:snapscore_android/features/essays/widgets/new_essay_form.dart';

class EditEssayScreen extends StatefulWidget {
  final String essayId;

  const EditEssayScreen({
    super.key,
    required this.essayId,
  });

  @override
  State<EditEssayScreen> createState() => _EditEssayScreenState();
}

class _EditEssayScreenState extends State<EditEssayScreen> {
  final EssayService _essayService = EssayService();
  final EssayFormController _formController = EssayFormController();
  bool _isLoading = true;
  EssayData? _initialData;

  @override
  void initState() {
    super.initState();
    _loadEssayData();
  }

  Future<void> _loadEssayData() async {
    try {
      final essayData = await _essayService.getEssay(widget.essayId);
      if (mounted) {
        // Extract questions with IDs
        final questions = essayData['essayQuestions']
            .asMap()
            .entries
            .map((entry) => EssayQuestion(
                  questionNumber: entry.key + 1,
                  questionText: entry.value['question'],
                  id: entry.value['id'], // Store the original ID
                ))
            .toList();

        // Get criteria with IDs
        final criteria = essayData['essayQuestions'][0]['essayCriteria']
            .asMap()
            .entries
            .map((entry) => EssayCriteria(
                  criteriaNumber: entry.key + 1,
                  criteriaText: entry.value['criteria'],
                  maxScore: (entry.value['maxScore'] as num).toDouble(),
                  id: entry.value['id'], // Store the original ID
                ))
            .toList();

        setState(() {
          _initialData = EssayData(
            essayTitle: essayData['name'],
            questions: List<EssayQuestion>.from(questions),
            criteria: List<EssayCriteria>.from(criteria),
            totalScore: criteria
                .map((c) => c.maxScore)
                .fold(0.0, (sum, score) => sum + score),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load essay data')),
        );
      }
    }
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    try {
      final essayData = EssayData.fromJson(formData);

      // Update essay title and total score if changed
      if (_initialData!.essayTitle != essayData.essayTitle ||
          _initialData!.totalScore != essayData.totalScore) {
        await _essayService.updateEssay(
          essayId: widget.essayId,
          essayTitle: essayData.essayTitle,
        );
      }

      // Update questions
      for (int i = 0; i < essayData.questions.length; i++) {
        if (i < _initialData!.questions.length) {
          final questionId = _initialData!.questions[i].id;
          if (questionId != null &&
              essayData.questions[i].questionText !=
                  _initialData!.questions[i].questionText) {
            await _essayService.updateQuestion(
              questionId: questionId,
              questionText: essayData.questions[i].questionText,
            );
          }
        }
      }

      // Update criteria
      for (int i = 0; i < essayData.criteria.length; i++) {
        if (i < _initialData!.criteria.length) {
          final criteriaId = _initialData!.criteria[i].id;
          if (criteriaId != null &&
              (essayData.criteria[i].criteriaText !=
                      _initialData!.criteria[i].criteriaText ||
                  essayData.criteria[i].maxScore !=
                      _initialData!.criteria[i].maxScore)) {
            await _essayService.updateCriteria(
              criteriaId: criteriaId,
              criteriaText: essayData.criteria[i].criteriaText,
              maxScore: essayData.criteria[i].maxScore,
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating essay: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update essay: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SnapScore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Center(
                  child: Text(
                    'Essay',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: NewEssayForm(
                    controller: _formController,
                    onSubmit: _handleSubmit,
                    initialData: _initialData,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomButton(
                        imagePath: "assets/icons/assessment_save.png",
                        label: 'Update',
                        onPressed: () => _formController.submitForm?.call(),
                      ),
                      _BottomButton(
                        imagePath: "assets/icons/assessment_scan.png",
                        label: 'Scan',
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Camera())),
                        },
                      ),
                      _BottomButton(
                        imagePath: "assets/icons/assessment_results.png",
                        label: 'Results',
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EssayResultsScreen(
                                assessmentId: widget.essayId,
                                essayTitle: _initialData!.essayTitle,
                              ),
                            ),
                          )
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const _BottomButton({
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100, // Fixed width for all buttons
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(height: 4), // Consistent spacing
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
