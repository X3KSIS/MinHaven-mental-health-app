import 'package:flutter/material.dart';

import 'bottom_sheet_handle.dart';
import '../../../themes/app_colors.dart';


class SelfCareTipsSheet extends StatelessWidget {
  final Color primaryColor;

  const SelfCareTipsSheet({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final tips = [
      {'icon': Icons.wb_sunny, 'title': 'Get Sunlight', 'desc': 'Spend 15-30 minutes outdoors daily'},
      {'icon': Icons.bedtime, 'title': 'Sleep Well', 'desc': 'Aim for 7-9 hours of quality sleep'},
      {'icon': Icons.directions_run, 'title': 'Move Your Body', 'desc': 'Exercise for at least 30 minutes'},
      {'icon': Icons.restaurant, 'title': 'Eat Nutritiously', 'desc': 'Fuel your body with healthy foods'},
      {'icon': Icons.people, 'title': 'Connect', 'desc': 'Reach out to friends and family'},
      {'icon': Icons.self_improvement, 'title': 'Practice Mindfulness', 'desc': 'Try meditation or deep breathing'},
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 20),
            Text(
              'Self-Care Tips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Small steps toward better mental health',
              style: TextStyle(color: context.textMuted),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            tip['icon'] as IconData,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip['desc'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}