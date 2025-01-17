import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../widgets/assessments_list.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: const [
                    Text(
                      'SnapScore',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Assessments',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            const AssessmentSearchWidget(),

            // New Assessment Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAssessmentTypeDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12), // reduced height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                          color: Colors.black, width: 1), // black border
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        'New Assessment',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // made text bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssessmentTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor:
          Colors.grey.withOpacity(0.2), // Semi-transparent dark background
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Type of Assessment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AssessmentTypeButton(
                          title: 'Identification',
                          iconPath: 'assets/images/assessment_test.png',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(
                          width: 16,
                          height: 32,
                        ),
                        _AssessmentTypeButton(
                          title: 'Essay',
                          iconPath: 'assets/images/assessment_essay.png',
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssessmentTypeButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _AssessmentTypeButton({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150, // Increased width
        height: 160, // Fixed height for consistency
        padding: const EdgeInsets.all(20), // Increased padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            Image.asset(
              iconPath,
              height: 72, // Larger icon
              width: 72,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16), // More spacing
            Text(
              title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14, // Larger text
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
