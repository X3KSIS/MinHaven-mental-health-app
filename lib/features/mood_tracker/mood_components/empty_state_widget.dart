import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onLogMood;

  const EmptyStateWidget({
    super.key,
    required this.primaryColor,
    required this.onLogMood,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mood_outlined,
              size: 100,
              color: primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'No mood entries yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your mood to see insights and trends over time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onLogMood,
              icon: const Icon(Icons.add),
              label: const Text('Log Your First Mood'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}