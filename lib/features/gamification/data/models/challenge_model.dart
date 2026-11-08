import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeType {
  daily,
  weekly,
  monthly,
  milestone
}

enum ChallengeCategory {
  mood,
  journal,
  chat,
  wellness,
  mixed
}

class Challenge {
  final String id;
  final String name;
  final String description;
  final ChallengeType type;
  final ChallengeCategory category;
  final int points;
  final int target;
  final int progress;
  final bool isCompleted;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final String iconEmoji;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.points,
    required this.target,
    this.progress = 0,
    this.isCompleted = false,
    this.isActive = true,
    required this.startDate,
    required this.endDate,
    required this.iconEmoji,
  });

  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  bool get isExpired => DateTime.now().isAfter(endDate);

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    ChallengeType? type,
    ChallengeCategory? category,
    int? points,
    int? target,
    int? progress,
    bool? isCompleted,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? iconEmoji,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      points: points ?? this.points,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'category': category.toString(),
      'points': points,
      'target': target,
      'progress': progress,
      'isCompleted': isCompleted,
      'isActive': isActive,
      'startDate': startDate,
      'endDate': endDate,
      'iconEmoji': iconEmoji,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: _parseTypeFromString(map['type']),
      category: _parseCategoryFromString(map['category']),
      points: map['points'] ?? 0,
      target: map['target'] ?? 1,
      progress: map['progress'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      isActive: map['isActive'] ?? true,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      iconEmoji: map['iconEmoji'] ?? '🎯',
    );
  }

  static ChallengeType _parseTypeFromString(String? type) {
    switch (type) {
      case 'ChallengeType.daily':
        return ChallengeType.daily;
      case 'ChallengeType.weekly':
        return ChallengeType.weekly;
      case 'ChallengeType.monthly':
        return ChallengeType.monthly;
      case 'ChallengeType.milestone':
        return ChallengeType.milestone;
      default:
        return ChallengeType.daily;
    }
  }

  static ChallengeCategory _parseCategoryFromString(String? category) {
    switch (category) {
      case 'ChallengeCategory.mood':
        return ChallengeCategory.mood;
      case 'ChallengeCategory.journal':
        return ChallengeCategory.journal;
      case 'ChallengeCategory.chat':
        return ChallengeCategory.chat;
      case 'ChallengeCategory.wellness':
        return ChallengeCategory.wellness;
      case 'ChallengeCategory.mixed':
        return ChallengeCategory.mixed;
      default:
        return ChallengeCategory.wellness;
    }
  }
}
