import 'package:flutter/material.dart';
import '../data/model/mood_entry.dart';

class MoodStatsCards extends StatelessWidget {
  final List<MoodEntryData> moods;
  final Color primaryColor;

  const MoodStatsCards({
    super.key,
    required this.moods,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final avgScore = moods.isNotEmpty
        ? (moods.map((m) => m.score).reduce((a, b) => a + b) / moods.length)
        : 0.0;
    final last7Days = moods.where((m) =>
    DateTime.now().difference(m.timestamp).inDays < 7
    ).toList();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average',
            avgScore.toStringAsFixed(1),
            Icons.show_chart,
            primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Week',
            '${last7Days.length}',
            Icons.calendar_today,
            primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${moods.length}',
            Icons.emoji_emotions,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}