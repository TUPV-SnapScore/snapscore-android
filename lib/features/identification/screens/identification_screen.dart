import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapscore_android/core/providers/auth_provider.dart';
import 'package:snapscore_android/features/identification/models/identification_model.dart';
import 'package:snapscore_android/features/identification/services/identification_submission.dart';
import '../../../core/themes/colors.dart';
import '../widgets/identification_form.dart';

class IdentificationFormData {
  final String assessmentName;
  final List<IdentificationAnswer> answers;

  IdentificationFormData({
    required this.assessmentName,
    required this.answers,
  });
}

class NewIdentificationScreen extends StatefulWidget {
  const NewIdentificationScreen({super.key});

  @override
  State<NewIdentificationScreen> createState() =>
      _NewIdentificationScreenState();
}

class _NewIdentificationScreenState extends State<NewIdentificationScreen> {
  final _formController = IdentificationFormController();

  Future<void> _handleSave() async {
    try {
      _formController.submitForm?.call();
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment saved successfully!')),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    try {
      final service = IdentificationService();
      String? userId =
          Provider.of<AuthProvider>(context, listen: false).user?.uid;

      // Convert the raw answers data to IdentificationAnswer objects
      final answers = (data['answers'] as List<dynamic>).map((answer) {
        return IdentificationAnswer(
          number: answer['number'] as int,
          answer: answer['answer'] as String,
        );
      }).toList();

      final formData = IdentificationFormData(
        assessmentName: data['assessmentName'] as String,
        answers: answers,
      );

      final result = await service.createAssessment(
        assessmentName: formData.assessmentName,
        answers: formData.answers,
        userId: userId!,
      );

      print(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: ${e.toString()}')),
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
        centerTitle: true,
        title: const Text(
          'SnapScore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Identification',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: IdentificationForm(
              controller: _formController,
              onSubmit: _handleFormSubmit,
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
                  label: 'Save',
                  onPressed: _handleSave,
                ),
                _BottomButton(
                  imagePath: "assets/icons/assessment_scan.png",
                  label: 'Scan',
                  onPressed: () {},
                ),
                _BottomButton(
                  imagePath: "assets/icons/assessment_results.png",
                  label: 'Results',
                  onPressed: () {},
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
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
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
