import 'package:flutter/material.dart';
import 'package:snapscore_android/core/themes/colors.dart';
import 'package:snapscore_android/features/essays/widgets/new_essay_form.dart';

class NewEssayScreen extends StatefulWidget {
  const NewEssayScreen({super.key});

  @override
  State<NewEssayScreen> createState() => _NewEssayScreenState();
}

class _NewEssayScreenState extends State<NewEssayScreen> {
  final _formController = EssayFormController();

  Future<void> _handleSave() async {
    try {
      _formController.submitForm?.call();
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay assessment saved successfully!')),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving essay assessment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    // Here you would typically make your HTTP request
    // Example:
    // final response = await http.post(
    //   Uri.parse('your-api-endpoint'),
    //   body: jsonEncode(data),
    //   headers: {'Content-Type': 'application/json'},
    // );

    // For now, just print the data
    print('Submitting essay data: $data');

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // You can throw an error here if the API call fails
    // if (response.statusCode != 200) {
    //   throw Exception('Failed to save essay assessment');
    // }
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
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
              'Essay',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: NewEssayForm(
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
                  icon: Icons.save,
                  label: 'Save',
                  onPressed: _handleSave,
                ),
                _BottomButton(
                  icon: Icons.camera_alt,
                  label: 'Scan',
                  onPressed: () {},
                ),
                _BottomButton(
                  icon: Icons.assessment,
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
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _BottomButton({
    required this.icon,
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
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
