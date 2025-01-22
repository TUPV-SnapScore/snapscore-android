import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../widgets/assessments_list.dart';
import '../widgets/settings_popup.dart';
import '../widgets/assessments_dialog.dart';

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
            onPressed: () {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final Offset offset = button.localToGlobal(Offset.zero);

              final RelativeRect position = RelativeRect.fromLTRB(
                MediaQuery.of(context).size.width - 200, // Position from right
                offset.dy +
                    AppBar().preferredSize.height +
                    25, // Position below AppBar + 20 pixels
                8, // Right padding
                0,
              );

              showSettingsPopup(context, position);
            },
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
                  onPressed: () => showAssessmentTypeDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 4), // reduced from 12 to 8
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
                          fontWeight: FontWeight.bold,
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
}
