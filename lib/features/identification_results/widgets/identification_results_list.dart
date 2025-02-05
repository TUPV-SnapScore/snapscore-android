import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/identification_results_model.dart';

class StudentResultsList extends StatefulWidget {
  final List<IdentificationResultModel> results;
  final Function(String) onStudentSelected;

  const StudentResultsList({
    Key? key,
    required this.results,
    required this.onStudentSelected,
  }) : super(key: key);

  @override
  State<StudentResultsList> createState() => _StudentResultsListState();
}

class _StudentResultsListState extends State<StudentResultsList> {
  List<IdentificationResultModel> filteredResults = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredResults = widget.results;
    searchController.addListener(_filterResults);
  }

  void _filterResults() {
    setState(() {
      filteredResults = widget.results
          .where((result) => result.studentName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      filteredResults = widget.results;
                      searchController.clear();
                    });
                  },
                  child: ListView.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = filteredResults[index];
                      return InkWell(
                        onTap: () => widget.onStudentSelected(result.id),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    result.studentName,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                result.scoreText,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
