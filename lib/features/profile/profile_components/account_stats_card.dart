import 'package:flutter/material.dart';

import '../utils/profile_utils.dart';
import '../../../themes/app_colors.dart';

class AccountStatsCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final Color primaryColor;

  const AccountStatsCard({
    super.key,
    required this.profile,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow(context, 
            'Member since',
            ProfileUtils.formatDate(profile['createdAt']),
          ),
          const Divider(height: 16),
          _buildStatRow(context, 
            'Last updated',
            ProfileUtils.formatDate(profile['updatedAt']),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: context.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}