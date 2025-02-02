import 'package:flutter/material.dart';
import 'package:snapscore_android/features/essay_results/models/essay_results_model.dart';

class StudentResultsList extends StatefulWidget {
  final List<EssayResult> results;
  final String searchQuery;
  final Function(String) onSearch;

  const StudentResultsList({
    super.key,
    required this.results,
    required this.searchQuery,
    required this.onSearch,
  });

  @override
  State<StudentResultsList> createState() => _StudentResultsListState();
}

class _StudentResultsListState extends State<StudentResultsList> {
  List<EssayResult> get filteredResults {
    if (widget.searchQuery.isEmpty) {
      return widget.results;
    }
    return widget.results
        .where((result) => result.studentName
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase()))
        .toList();
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
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              final result = filteredResults[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(result.studentName),
                  trailing: Text(
                    result.totalScore.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Navigate to detailed results view
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
