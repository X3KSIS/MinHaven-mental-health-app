import 'package:flutter/material.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}