import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final Color primaryColor;
  final int maxLines;
  final TextInputType? keyboardType;

  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.primaryColor,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? primaryColor.withValues(alpha: 0.3) : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: controller,
                    enabled: enabled,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Not set',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}