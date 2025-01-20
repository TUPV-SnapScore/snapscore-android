import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/identification_model.dart';

typedef OnSubmitCallback = Future<void> Function(Map<String, dynamic> data);

// Create a form controller to expose public methods
class IdentificationFormController {
  void Function()? submitForm;
}

class IdentificationForm extends StatefulWidget {
  final OnSubmitCallback onSubmit;
  final IdentificationFormController controller;

  const IdentificationForm({
    super.key,
    required this.onSubmit,
    required this.controller,
  });

  @override
  State<IdentificationForm> createState() => _IdentificationFormState();
}

class _IdentificationFormState extends State<IdentificationForm> {
  int selectedQuestions = 10;
  final List<int> questionOptions = [10, 20, 30, 40, 50];
  final List<TextEditingController> answerControllers = [];
  final TextEditingController titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.submitForm = _submitForm;
    _initializeAnswerControllers(10);
  }

  void _initializeAnswerControllers(int count) {
    // Clear existing controllers
    for (var controller in answerControllers) {
      controller.dispose();
    }
    answerControllers.clear();

    // Add new controllers
    for (int i = 0; i < count; i++) {
      answerControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in answerControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate form
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an assessment name')),
      );
      return;
    }

    // Check if all required answers are filled
    if (answerControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all answers')),
      );
      return;
    }

    // Build and submit the JSON data
    final jsonData = buildJsonRequest();
    await widget.onSubmit(jsonData);
  }

  // JSON Request Builder Method
  Map<String, dynamic> buildJsonRequest() {
    List<IdentificationAnswer> answers = [];
    for (int i = 0; i < answerControllers.length; i++) {
      if (answerControllers[i].text.isNotEmpty) {
        answers.add(IdentificationAnswer(
          number: i + 1,
          answer: answerControllers[i].text,
        ));
      }
    }

    IdentificationData identificationData = IdentificationData(
      assessmentName: titleController.text,
      numberOfQuestions: selectedQuestions,
      answers: answers,
    );

    return identificationData.toJson();
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
            _buildFormLabel('Assessment Name:'),
            _buildTextField(
              hintText: 'Input quiz name',
              prefixIcon: Icons.edit,
              controller: titleController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.question_answer,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pick Number of Questions:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
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
                      _initializeAnswerControllers(newValue);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildFormLabel('Answer Key:'),
            ...List.generate(
                selectedQuestions,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${index + 1}.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildTextField(
                              hintText: 'Answer ${index + 1}',
                              prefixIcon: Icons.edit,
                              controller: answerControllers[index],
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool enabled = true,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
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
