import 'package:flutter/material.dart';
import '../utils/mood_utils.dart';

class MoodDialog extends StatefulWidget {
  final Function(int, String?) onLogMood;

  const MoodDialog({super.key, required this.onLogMood});

  @override
  State<MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<MoodDialog> {
  int selectedScore = 5;
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final moodColor = MoodUtils.getMoodColor(selectedScore);
    final moodEmoji = MoodUtils.getMoodEmoji(selectedScore);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Log Your Mood'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How are you feeling right now?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                moodEmoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$selectedScore / 10',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: moodColor,
              ),
            ),
            Slider(
              value: selectedScore.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: moodColor,
              onChanged: (value) {
                setState(() {
                  selectedScore = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind? (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onLogMood(
              selectedScore,
              noteController.text.isEmpty ? null : noteController.text,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: moodColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Log Mood'),
        ),
      ],
    );
  }
}