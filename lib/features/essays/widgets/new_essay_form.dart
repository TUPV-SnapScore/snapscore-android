import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/essay_model.dart';

class EssayFormController {
  void Function()? submitForm;
}

// Update the NewEssayForm widget to accept controller and onSubmit callback
class NewEssayForm extends StatefulWidget {
  final EssayFormController controller;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final EssayData? initialData;

  const NewEssayForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<NewEssayForm> createState() => _NewEssayFormState();
}

class _NewEssayFormState extends State<NewEssayForm> {
  late int selectedQuestions;
  final List<int> questionOptions = [1, 3, 5];
  final List<TextEditingController> questionControllers = [];
  final List<TextEditingController> criteriaControllers = [];
  final List<TextEditingController> criteriaScoreControllers = [];
  final List<List<RubricLevel>> rubricLevels = [];
  final TextEditingController titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _submitForm() async {
    if (titleController.text.isEmpty) {
      throw Exception('Please enter an essay title');
    }

    if (questionControllers.any((controller) => controller.text.isEmpty)) {
      throw Exception('Please fill in all essay questions');
    }

    if (criteriaControllers.any((controller) => controller.text.isEmpty) ||
        criteriaScoreControllers.any((controller) => controller.text.isEmpty)) {
      throw Exception('Please fill in all criteria and scores');
    }

    // Validate rubric levels
    for (var levels in rubricLevels) {
      if (levels.any((level) => level.controller.text.isEmpty)) {
        throw Exception('Please fill in all rubric descriptions');
      }
    }

    final jsonData = buildJsonRequest();
    await widget.onSubmit(jsonData);
  }

  Map<String, dynamic> buildJsonRequest() {
    List<EssayQuestion> questions = [];
    for (int i = 0; i < questionControllers.length; i++) {
      questions.add(EssayQuestion(
        questionNumber: i + 1,
        question: questionControllers[i].text,
        id: widget.initialData?.questions[i].id ?? 'temp_q${i + 1}',
        essayCriteria: [],
        assessmentId: widget.initialData?.id ?? '',
      ));
    }

    List<EssayCriteria> criteria = [];
    for (int i = 0; i < criteriaControllers.length; i++) {
      List<Rubric> rubrics = [];
      for (var level in rubricLevels[i]) {
        rubrics.add(Rubric(
          id: 'temp_r${rubrics.length + 1}',
          score: level.score.toString(),
          description: level.description,
          criteriaId: widget.initialData?.criteria[i].id ?? 'temp_c${i + 1}',
        ));
      }

      criteria.add(EssayCriteria(
        criteriaNumber: i + 1,
        criteria: criteriaControllers[i].text,
        maxScore: int.parse(criteriaScoreControllers[i].text),
        id: widget.initialData?.criteria[i].id ?? 'temp_c${i + 1}',
        rubrics: rubrics,
        essayQuestionId: questions[0].id,
      ));
    }

    double totalScore = criteriaScoreControllers
        .map((controller) => double.tryParse(controller.text) ?? 0.0)
        .fold(0.0, (sum, score) => sum + score);

    return EssayData(
      essayTitle: titleController.text,
      questions: questions,
      criteria: criteria,
      totalScore: totalScore,
      id: widget.initialData?.id,
    ).toJson();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.submitForm = _submitForm;

    if (widget.initialData != null) {
      titleController.text = widget.initialData!.essayTitle;
      selectedQuestions = widget.initialData!.questions.length;

      for (var question in widget.initialData!.questions) {
        questionControllers.add(TextEditingController(text: question.question));
      }

      for (var criterion in widget.initialData!.criteria) {
        criteriaControllers
            .add(TextEditingController(text: criterion.criteria));
        criteriaScoreControllers
            .add(TextEditingController(text: criterion.maxScore.toString()));

        // Initialize rubric levels from existing data
        List<RubricLevel> levels = criterion.rubrics
            .map((r) => RubricLevel(
                initialScore: int.parse(r.score), description: r.description))
            .toList();
        rubricLevels.add(levels);
      }
    } else {
      // Default initialization
      selectedQuestions = questionOptions.first;
      questionControllers.add(TextEditingController());
      criteriaControllers.add(TextEditingController());
      criteriaScoreControllers.add(TextEditingController());

      // Initialize with 3 default rubric levels
      rubricLevels.add([
        RubricLevel(initialScore: 20, description: "Excellent performance"),
        RubricLevel(initialScore: 15, description: "Good performance"),
        RubricLevel(initialScore: 10, description: "Needs improvement"),
      ]);
    }
  }

  void addRubricLevel(int criteriaIndex) {
    if (rubricLevels[criteriaIndex].length < 5) {
      setState(() {
        rubricLevels[criteriaIndex].add(
          RubricLevel(
            initialScore: 5,
            description: "",
          ),
        );
      });
    }
  }

  void removeRubricLevel(int criteriaIndex, int levelIndex) {
    if (rubricLevels[criteriaIndex].length > 3) {
      setState(() {
        final level = rubricLevels[criteriaIndex].removeAt(levelIndex);
        level.dispose();
      });
    }
  }

  // Update the build method for rubric levels
  Widget _buildRubricLevels(int criteriaIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(
          rubricLevels[criteriaIndex].length,
          (levelIndex) => Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller:
                        rubricLevels[criteriaIndex][levelIndex].scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      suffix: Text('pts'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('-'),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(
                    hintText: 'Rubric description',
                    controller:
                        rubricLevels[criteriaIndex][levelIndex].controller,
                  ),
                ),
                if (rubricLevels[criteriaIndex].length > 3)
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: AppColors.error),
                    onPressed: () =>
                        removeRubricLevel(criteriaIndex, levelIndex),
                  ),
              ],
            ),
          ),
        ),
        if (rubricLevels[criteriaIndex].length < 5)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: TextButton(
              onPressed: () => addRubricLevel(criteriaIndex),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Add Rubric Level',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void updateQuestionFields(int count) {
    if (count > questionControllers.length) {
      while (questionControllers.length < count) {
        questionControllers.add(TextEditingController());
      }
    } else if (count < questionControllers.length) {
      while (questionControllers.length > count) {
        final controller = questionControllers.removeLast();
        controller.dispose();
      }
    }
    setState(() {});
  }

  void addCriteria() {
    // Disable adding criteria in edit mode
    if (widget.initialData != null) return;

    if (criteriaControllers.length < 5) {
      setState(() {
        criteriaControllers.add(TextEditingController());
        criteriaScoreControllers.add(TextEditingController());
        // Add default rubric levels for the new criteria
        rubricLevels.add([
          RubricLevel(initialScore: 20, description: "Excellent performance"),
          RubricLevel(initialScore: 15, description: "Good performance"),
          RubricLevel(initialScore: 10, description: "Needs improvement"),
        ]);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

// Also update the removeCriteria method to clean up rubric levels
  void removeCriteria(int index) {
    // Disable removing criteria in edit mode
    if (widget.initialData != null) return;

    if (criteriaControllers.length > 1) {
      setState(() {
        criteriaControllers[index].dispose();
        criteriaControllers.removeAt(index);
        criteriaScoreControllers[index].dispose();
        criteriaScoreControllers.removeAt(index);

        // Dispose and remove rubric levels for this criteria
        for (var level in rubricLevels[index]) {
          level.dispose();
        }
        rubricLevels.removeAt(index);
      });
    }
  }

  void updateTotalScore() {
    double total = 0;
    for (var controller in criteriaScoreControllers) {
      total += double.tryParse(controller.text) ?? 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var levels in rubricLevels) {
      for (var level in levels) {
        level.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormLabel('Essay Name:'),
            _buildTextField(
              hintText: 'Input essay title',
              prefixIconAsset: "assets/icons/rubric_item.png",
              controller: titleController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Image.asset(
                  "assets/icons/rubric_item.png",
                  width: 20,
                  height: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pick Number of Questions:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: selectedQuestions,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: questionOptions.map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: widget.initialData != null
                          ? null
                          : (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedQuestions = newValue;
                                  updateQuestionFields(newValue);
                                });
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFormLabel('Essay Questions:'),
            ...List.generate(
                questionControllers.length,
                (index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index > 0) const SizedBox(height: 12),
                        Text(
                          'Question ${index + 1}:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hintText: 'Input question ${index + 1}',
                          prefixIconAsset: "assets/icons/rubric_item.png",
                          controller: questionControllers[index],
                        ),
                      ],
                    )),
            const SizedBox(height: 20),
            _buildFormLabel('Rubrics:'),
            ...List.generate(
              criteriaControllers.length,
              (criteriaIndex) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (criteriaIndex > 0) const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          hintText: 'Input essay criteria',
                          prefixIconAsset: "assets/icons/rubric_item.png",
                          controller: criteriaControllers[criteriaIndex],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          hintText: 'Score',
                          controller: criteriaScoreControllers[criteriaIndex],
                          keyboardType: TextInputType.number,
                          onChanged: (_) => updateTotalScore(),
                        ),
                      ),
                      if (widget.initialData?.id?.isNotEmpty != true)
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () => removeCriteria(criteriaIndex),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRubricLevels(criteriaIndex),
                ],
              ),
            ),
            if (widget.initialData?.id == null ||
                !widget.initialData!.id!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextButton(
                  onPressed: addCriteria,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Add Criteria',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _buildFormLabel('Total Score:'),
            _buildTextField(
              hintText: 'Total Score',
              prefixIconAsset: "assets/icons/rubric_item.png",
              enabled: false,
              controller: TextEditingController(
                text: criteriaScoreControllers
                    .map(
                        (controller) => double.tryParse(controller.text) ?? 0.0)
                    .fold(0.0, (sum, score) => sum + score)
                    .toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 32),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    String? prefixIconAsset, // Changed to String for asset path
    IconData? suffixIcon,
    bool enabled = true,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          prefixIcon: prefixIconAsset != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(prefixIconAsset),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.textSecondary)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class RubricLevel {
  final TextEditingController scoreController;
  final TextEditingController controller;

  RubricLevel({
    required int initialScore,
    required String description,
  })  : scoreController = TextEditingController(text: initialScore.toString()),
        controller = TextEditingController(text: description);

  int get score => int.tryParse(scoreController.text) ?? 0;
  String get description => controller.text;

  void dispose() {
    scoreController.dispose();
    controller.dispose();
  }
}
