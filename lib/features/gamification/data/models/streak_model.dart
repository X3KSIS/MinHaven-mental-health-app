import 'package:cloud_firestore/cloud_firestore.dart';

enum StreakType {
  mood,
  journal,
  chat,
  overall
}

class Streak {
  final StreakType type;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final DateTime streakStartDate;
  final int totalActiveDays;

  Streak({
    required this.type,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.streakStartDate,
    required this.totalActiveDays,
  });

  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate).inDays;
    return difference <= 1;
  }

  Streak copyWith({
    StreakType? type,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    DateTime? streakStartDate,
    int? totalActiveDays,
  }) {
    return Streak(
      type: type ?? this.type,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate,
      'streakStartDate': streakStartDate,
      'totalActiveDays': totalActiveDays,
    };
  }

  factory Streak.fromMap(Map<String, dynamic> map, StreakType type) {
    return Streak(
      type: type,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActivityDate: (map['lastActivityDate'] as Timestamp).toDate(),
      streakStartDate: (map['streakStartDate'] as Timestamp).toDate(),
      totalActiveDays: map['totalActiveDays'] ?? 0,
    );
  }
}
