import 'package:cloud_firestore/cloud_firestore.dart';

class UserGamificationProfile {
  final String userId;
  final int totalPoints;
  final int currentLevel;
  final double levelProgress;
  final DateTime joinedDate;
  final DateTime lastActivityDate;
  final Map<String, int> categoryPoints;

  UserGamificationProfile({
    required this.userId,
    required this.totalPoints,
    required this.currentLevel,
    required this.levelProgress,
    required this.joinedDate,
    required this.lastActivityDate,
    required this.categoryPoints,
  });

  int get pointsToNextLevel {
    final nextLevelThreshold = _getLevelThreshold(currentLevel + 1);
    final currentLevelThreshold = _getLevelThreshold(currentLevel);
    return nextLevelThreshold - totalPoints;
  }

  int get pointsInCurrentLevel {
    final currentLevelThreshold = _getLevelThreshold(currentLevel);
    return totalPoints - currentLevelThreshold;
  }

  int get pointsRequiredForCurrentLevel {
    final nextLevelThreshold = _getLevelThreshold(currentLevel + 1);
    final currentLevelThreshold = _getLevelThreshold(currentLevel);
    return nextLevelThreshold - currentLevelThreshold;
  }

  String get levelTitle {
    switch (currentLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Explorer';
      case 3:
        return 'Learner';
      case 4:
        return 'Practitioner';
      case 5:
        return 'Dedicated';
      case 6:
        return 'Committed';
      case 7:
        return 'Advanced';
      case 8:
        return 'Expert';
      case 9:
        return 'Master';
      case 10:
        return 'Champion';
      default:
        return currentLevel > 10 ? 'Legend' : 'Beginner';
    }
  }

  static int _getLevelThreshold(int level) {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 250;
      case 4:
        return 500;
      case 5:
        return 1000;
      case 6:
        return 2000;
      case 7:
        return 3500;
      case 8:
        return 5500;
      case 9:
        return 8000;
      case 10:
        return 12000;
      case 11:
        return 20000;
      default:
        return level > 11 ? 20000 + ((level - 11) * 10000) : 0;
    }
  }

  static int calculateLevel(int totalPoints) {
    int level = 1;
    while (_getLevelThreshold(level + 1) <= totalPoints) {
      level++;
    }
    return level;
  }

  static double calculateLevelProgress(int totalPoints, int currentLevel) {
    final currentThreshold = _getLevelThreshold(currentLevel);
    final nextThreshold = _getLevelThreshold(currentLevel + 1);
    final pointsInLevel = totalPoints - currentThreshold;
    final pointsNeeded = nextThreshold - currentThreshold;
    return pointsNeeded > 0 ? (pointsInLevel / pointsNeeded).clamp(0.0, 1.0) : 0.0;
  }

  UserGamificationProfile copyWith({
    String? userId,
    int? totalPoints,
    int? currentLevel,
    double? levelProgress,
    DateTime? joinedDate,
    DateTime? lastActivityDate,
    Map<String, int>? categoryPoints,
  }) {
    return UserGamificationProfile(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      levelProgress: levelProgress ?? this.levelProgress,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      categoryPoints: categoryPoints ?? this.categoryPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'levelProgress': levelProgress,
      'joinedDate': joinedDate,
      'lastActivityDate': lastActivityDate,
      'categoryPoints': categoryPoints,
    };
  }

  factory UserGamificationProfile.fromMap(Map<String, dynamic> map) {
    return UserGamificationProfile(
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      currentLevel: map['currentLevel'] ?? 1,
      levelProgress: (map['levelProgress'] ?? 0.0).toDouble(),
      joinedDate: (map['joinedDate'] as Timestamp).toDate(),
      lastActivityDate: (map['lastActivityDate'] as Timestamp).toDate(),
      categoryPoints: Map<String, int>.from(map['categoryPoints'] ?? {}),
    );
  }

  factory UserGamificationProfile.initial(String userId) {
    final now = DateTime.now();
    return UserGamificationProfile(
      userId: userId,
      totalPoints: 0,
      currentLevel: 1,
      levelProgress: 0.0,
      joinedDate: now,
      lastActivityDate: now,
      categoryPoints: {
        'mood': 0,
        'journal': 0,
        'chat': 0,
        'wellness': 0,
      },
    );
  }
}
