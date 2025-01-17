import 'package:flutter/material.dart';

void showSettingsPopup(BuildContext context, RelativeRect position) {
  showMenu(
    context: context,
    position: position,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.black, width: 1),
    ),
    elevation: 0,
    items: [
      PopupMenuItem(
        height: 40,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings,
                size: 20,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
