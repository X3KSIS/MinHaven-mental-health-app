import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class AboutDialog extends StatelessWidget {
  final Color primaryColor;

  const AboutDialog({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            'About MindHaven',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'MindHaven is your compassionate mental health companion, designed to provide support, guidance, and a safe space for students.',
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Created by Paul Mubanga',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 MindHaven. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: context.textFaint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(color: primaryColor),
          ),
        ),
      ],
    );
  }
}