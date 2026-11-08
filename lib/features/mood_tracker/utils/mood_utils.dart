import 'package:flutter/material.dart';

class MoodUtils {
  static Color getMoodColor(int score) {
    if (score <= 3) return Colors.red;
    if (score <= 5) return Colors.orange;
    if (score <= 7) return Colors.amber;
    return Colors.green;
  }

  static String getMoodEmoji(int score) {
    if (score <= 2) return '😢';
    if (score <= 4) return '😕';
    if (score <= 6) return '😐';
    if (score <= 8) return '🙂';
    return '😄';
  }

  static String getMoodLabel(int score) {
    if (score <= 3) return 'Low';
    if (score <= 7) return 'Good';
    return 'Great';
  }
}