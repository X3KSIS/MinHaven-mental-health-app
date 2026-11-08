import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/model/mood_entry.dart';
import '../utils/mood_utils.dart';

class RecentMoodsList extends StatelessWidget {
  final List<MoodEntryData> moods;
  final Color primaryColor;

  const RecentMoodsList({
    super.key,
    required this.moods,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Recent Moods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${moods.length} total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final mood = moods[index];
              final date = DateFormat('MMM dd').format(mood.timestamp);
              final time = DateFormat('h:mm a').format(mood.timestamp);
              final moodColor = MoodUtils.getMoodColor(mood.score);
              final moodEmoji = MoodUtils.getMoodEmoji(mood.score);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(moodEmoji, style: const TextStyle(fontSize: 20)),
                        Text(
                          '${mood.score}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: moodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Text(
                  '$date at $time',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  mood.note.isEmpty ? 'No note added' : mood.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mood.note.isEmpty ? Colors.grey[400] : Colors.grey[700],
                    fontStyle: mood.note.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    MoodUtils.getMoodLabel(mood.score),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: moodColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}