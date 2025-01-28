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

  const NewEssayForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  State<NewEssayForm> createState() => _NewEssayFormState();
}

class _NewEssayFormState extends State<NewEssayForm> {
  int selectedQuestions = 1;
  final List<int> questionOptions = [1, 3, 5];
  final List<TextEditingController> questionControllers = [];
  final List<TextEditingController> criteriaControllers = [];
  final List<TextEditingController> criteriaScoreControllers = [];
  final TextEditingController titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.submitForm = _submitForm;
    questionControllers.add(TextEditingController());
    criteriaControllers.add(TextEditingController());
    criteriaScoreControllers.add(TextEditingController());
  }

  Future<void> _submitForm() async {
    // Validate form
    if (titleController.text.isEmpty) {
      throw Exception('Please enter an essay title');
    }

    // Check if all questions are filled
    if (questionControllers.any((controller) => controller.text.isEmpty)) {
      throw Exception('Please fill in all essay questions');
    }

    // Check if all criteria and scores are filled
    if (criteriaControllers.any((controller) => controller.text.isEmpty) ||
        criteriaScoreControllers.any((controller) => controller.text.isEmpty)) {
      throw Exception('Please fill in all criteria and scores');
    }

    // Validate score inputs
    for (var controller in criteriaScoreControllers) {
      if (double.tryParse(controller.text) == null) {
        throw Exception('Please enter valid numeric scores');
      }
    }

    // Build and submit the JSON data
    final jsonData = buildJsonRequest();
    await widget.onSubmit(jsonData);
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in criteriaControllers) {
      controller.dispose();
    }
    for (var controller in criteriaScoreControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // JSON Request Builder Method
  Map<String, dynamic> buildJsonRequest() {
    // Build questions list
    List<EssayQuestion> questions = [];
    for (int i = 0; i < questionControllers.length; i++) {
      if (questionControllers[i].text.isNotEmpty) {
        questions.add(EssayQuestion(
          questionNumber: i + 1,
          questionText: questionControllers[i].text,
        ));
      }
    }

    // Build criteria list
    List<EssayCriteria> criteria = [];
    for (int i = 0; i < criteriaControllers.length; i++) {
      if (criteriaControllers[i].text.isNotEmpty) {
        criteria.add(EssayCriteria(
          criteriaNumber: i + 1,
          criteriaText: criteriaControllers[i].text,
          maxScore: double.tryParse(criteriaScoreControllers[i].text) ?? 0.0,
        ));
      }
    }

    // Calculate total score
    double totalScore = criteriaScoreControllers
        .map((controller) => double.tryParse(controller.text) ?? 0.0)
        .fold(0.0, (sum, score) => sum + score);

    // Create essay data object
    EssayData essayData = EssayData(
      essayTitle: titleController.text,
      questions: questions,
      criteria: criteria,
      totalScore: totalScore,
    );

    // Return JSON representation
    return essayData.toJson();
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
    if (criteriaControllers.length < 5) {
      setState(() {
        criteriaControllers.add(TextEditingController());
        criteriaScoreControllers.add(TextEditingController());
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

  void removeCriteria(int index) {
    if (criteriaControllers.length > 1) {
      setState(() {
        criteriaControllers[index].dispose();
        criteriaControllers.removeAt(index);
        criteriaScoreControllers[index].dispose();
        criteriaScoreControllers.removeAt(index);
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
                      onChanged: (int? newValue) {
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
                (index) => Column(
                      children: [
                        if (index > 0) const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                hintText: 'Input essay criteria',
                                prefixIconAsset: "assets/icons/rubric_item.png",
                                controller: criteriaControllers[index],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildTextField(
                                hintText: 'Score',
                                controller: criteriaScoreControllers[index],
                                keyboardType: TextInputType.number,
                                onChanged: (_) => updateTotalScore(),
                              ),
                            ),
                            if (index > 0 || criteriaControllers.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () => removeCriteria(index),
                              ),
                          ],
                        ),
                      ],
                    )),
            const SizedBox(height: 12),
            if (criteriaControllers.length < 5)
              TextButton(
                onPressed: addCriteria,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize:
                      const Size.fromHeight(50), // Makes button take full width
                ),
                child: Container(
                  width: double.infinity, // Makes container take full width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Centers the content
                    children: [
                      Icon(Icons.add, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'Insert additional essay criteria',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Makes text bold
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
