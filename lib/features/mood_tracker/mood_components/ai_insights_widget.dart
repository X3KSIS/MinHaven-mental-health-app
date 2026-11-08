import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class AIInsightsWidget extends StatelessWidget {
  final String insight;
  final bool isLoading;
  final Color primaryColor;

  const AIInsightsWidget({
    super.key,
    required this.insight,
    required this.isLoading,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}