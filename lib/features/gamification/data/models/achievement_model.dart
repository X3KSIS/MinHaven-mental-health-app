import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond
}

enum AchievementCategory {
  mood,
  journal,
  chat,
  wellness,
  streak,
  special
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final AchievementTier tier;
  final int points;
  final int target;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String iconEmoji;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tier,
    required this.points,
    required this.target,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.iconEmoji,
  });

  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    AchievementCategory? category,
    AchievementTier? tier,
    int? points,
    int? target,
    int? progress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? iconEmoji,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      points: points ?? this.points,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.toString(),
      'tier': tier.toString(),
      'points': points,
      'target': target,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt,
      'iconEmoji': iconEmoji,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: _parseCategoryFromString(map['category']),
      tier: _parseTierFromString(map['tier']),
      points: map['points'] ?? 0,
      target: map['target'] ?? 1,
      progress: map['progress'] ?? 0,
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null 
          ? (map['unlockedAt'] as Timestamp).toDate() 
          : null,
      iconEmoji: map['iconEmoji'] ?? '🏆',
    );
  }

  static AchievementCategory _parseCategoryFromString(String? category) {
    switch (category) {
      case 'AchievementCategory.mood':
        return AchievementCategory.mood;
      case 'AchievementCategory.journal':
        return AchievementCategory.journal;
      case 'AchievementCategory.chat':
        return AchievementCategory.chat;
      case 'AchievementCategory.wellness':
        return AchievementCategory.wellness;
      case 'AchievementCategory.streak':
        return AchievementCategory.streak;
      case 'AchievementCategory.special':
        return AchievementCategory.special;
      default:
        return AchievementCategory.wellness;
    }
  }

  static AchievementTier _parseTierFromString(String? tier) {
    switch (tier) {
      case 'AchievementTier.bronze':
        return AchievementTier.bronze;
      case 'AchievementTier.silver':
        return AchievementTier.silver;
      case 'AchievementTier.gold':
        return AchievementTier.gold;
      case 'AchievementTier.platinum':
        return AchievementTier.platinum;
      case 'AchievementTier.diamond':
        return AchievementTier.diamond;
      default:
        return AchievementTier.bronze;
    }
  }
}
