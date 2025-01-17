import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';

class AssessmentSearchWidget extends StatefulWidget {
  const AssessmentSearchWidget({super.key});

  @override
  State<AssessmentSearchWidget> createState() => _AssessmentSearchWidgetState();
}

class _AssessmentSearchWidgetState extends State<AssessmentSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _sampleAssessments = [
    {
      'title': 'Sample Test',
      'type': 'test',
      'iconPath': 'assets/images/assessment_test.png',
    },
    {
      'title': 'Sample Essay',
      'type': 'essay',
      'iconPath': 'assets/images/assessment_essay.png',
    },
  ];

  List<Map<String, dynamic>> _filteredAssessments = [];

  @override
  void initState() {
    super.initState();
    _filteredAssessments = _sampleAssessments;
  }

  void _filterAssessments(String query) {
    setState(() {
      _filteredAssessments = _sampleAssessments
          .where((assessment) =>
              assessment['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: _filterAssessments,
              decoration: InputDecoration(
                hintText: 'Search',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Assessment List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: _filteredAssessments.map((assessment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _AssessmentListItem(
                  title: assessment['title'],
                  iconPath: assessment['iconPath'],
                  onTap: () {},
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _AssessmentListItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _AssessmentListItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96, // Increased height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  iconPath,
                  height: 128, // Increased image size
                  width: 128,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
