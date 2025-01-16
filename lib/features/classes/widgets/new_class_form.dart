import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';

class NewClassForm extends StatefulWidget {
  final VoidCallback onCancel;

  const NewClassForm({
    super.key,
    required this.onCancel,
  });

  @override
  State<NewClassForm> createState() => _NewClassFormState();
}

class _NewClassFormState extends State<NewClassForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Class Name',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle class creation
                widget.onCancel();
              },
              child: const Text('Create Class'),
            ),
          ],
        ),
      ],
    );
  }
}
