import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/model/mood_entry.dart';
import '../utils/mood_utils.dart';

class MoodChartWidget extends StatelessWidget {
  final List<MoodEntryData> moods;
  final Color primaryColor;

  const MoodChartWidget({
    super.key,
    required this.moods,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final chartMoods = moods.take(7).toList().reversed.toList();
    if (chartMoods.isEmpty) return const SizedBox.shrink();

    final trend = _calculateTrend(chartMoods);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Mood Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: trend.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(trend.icon, size: 16, color: trend.color),
                    const SizedBox(width: 4),
                    Text(
                      trend.text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: trend.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegend(),
          const SizedBox(height: 16),
          _buildBarChart(chartMoods),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('😢 Low', Colors.red),
        const SizedBox(width: 12),
        _buildLegendItem('😐 Medium', Colors.amber),
        const SizedBox(width: 12),
        _buildLegendItem('😄 High', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<MoodEntryData> chartMoods) {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(chartMoods.length, (index) {
          final mood = chartMoods[index];
          final barHeight = (mood.score / 10.0) * 120;
          final barColor = MoodUtils.getMoodColor(mood.score);
          final emoji = MoodUtils.getMoodEmoji(mood.score);
          final date = DateFormat('EEE').format(mood.timestamp);
          final isToday = DateTime.now().difference(mood.timestamp).inDays == 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    '${mood.score}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [barColor, barColor.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isToday ? 'Today' : date,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? primaryColor : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  _TrendData _calculateTrend(List<MoodEntryData> chartMoods) {
    if (chartMoods.length < 2) {
      return _TrendData('Stable', Icons.trending_flat, Colors.blue);
    }

    final recent = chartMoods.skip(chartMoods.length > 3 ? chartMoods.length - 3 : 0)
        .map((m) => m.score).reduce((a, b) => a + b) / (chartMoods.length > 3 ? 3 : chartMoods.length);
    final earlier = chartMoods.take(chartMoods.length > 3 ? 3 : chartMoods.length)
        .map((m) => m.score).reduce((a, b) => a + b) / (chartMoods.length > 3 ? 3 : chartMoods.length);
    final diff = recent - earlier;

    if (diff > 0.5) {
      return _TrendData('Improving', Icons.trending_up, Colors.green);
    } else if (diff < -0.5) {
      return _TrendData('Declining', Icons.trending_down, Colors.orange);
    } else {
      return _TrendData('Stable', Icons.trending_flat, Colors.blue);
    }
  }
}

class _TrendData {
  final String text;
  final IconData icon;
  final Color color;

  _TrendData(this.text, this.icon, this.color);
}