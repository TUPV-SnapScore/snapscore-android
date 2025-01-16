import 'package:flutter/material.dart';
import 'new_class_form.dart';
import '../../../core/themes/colors.dart';

// Class model for the list
class ClassItem {
  final String name;
  final String description;

  ClassItem({required this.name, required this.description});
}

// Main class screen content widget
class ClassScreenContent extends StatefulWidget {
  const ClassScreenContent({super.key});

  @override
  State<ClassScreenContent> createState() => _ClassScreenContentState();
}

class _ClassScreenContentState extends State<ClassScreenContent> {
  bool _showNewClassForm = false;
  final _searchController = TextEditingController();

  // Sample data - replace with your actual data source
  final List<ClassItem> _classes = [
    ClassItem(
        name: 'Mathematics 101', description: 'Introduction to Mathematics'),
    ClassItem(name: 'Physics 101', description: 'Introduction to Physics'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Class',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        if (!_showNewClassForm) ...[
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8), // Added vertical padding
            constraints:
                const BoxConstraints(maxHeight: 40), // Added height constraint
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      isDense: true, // Makes the TextField more compact
                      contentPadding:
                          EdgeInsets.zero, // Removes internal padding
                    ),
                  ),
                ),
                Icon(Icons.search, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: () {
              setState(() {
                _showNewClassForm = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.grey, weight: 900, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'New Class',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Classes List
          Expanded(
            child: ListView.builder(
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      _classes[index].name,
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      // Handle class selection
                    },
                    visualDensity: VisualDensity(
                        vertical: -4), // This makes the tile more compact
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0), // Reduced vertical padding
                  ),
                );
              },
            ),
          ),
        ] else ...[
          // New Class Form
          NewClassForm(
            onCancel: () {
              setState(() {
                _showNewClassForm = false;
              });
            },
          ),
        ],
      ],
    );
  }
}
