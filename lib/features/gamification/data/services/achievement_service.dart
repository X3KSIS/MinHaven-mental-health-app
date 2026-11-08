import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';
import '../../utils/achievement_definitions.dart';
import 'points_service.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointsService _pointsService = PointsService();

  Future<void> checkAndUnlockAchievements(String userId, String action, Map<String, dynamic> stats) async {
    final allAchievements = AchievementDefinitions.allDefinitions;
    
    for (final achievementDef in allAchievements) {
      final userAchievement = await getAchievement(userId, achievementDef.id);
      
      // Skip if already unlocked
      if (userAchievement != null && userAchievement.isUnlocked) {
        continue;
      }

      // Check if achievement should be unlocked
      final shouldUnlock = _checkAchievementCriteria(achievementDef, stats);
      
      if (shouldUnlock) {
        await unlockAchievement(userId, achievementDef);
      } else {
        // Update progress
        final progress = _calculateProgress(achievementDef, stats);
        await updateAchievementProgress(userId, achievementDef.id, progress);
      }
    }
  }

  bool _checkAchievementCriteria(Achievement achievement, Map<String, dynamic> stats) {
    switch (achievement.id) {
      // Mood achievements
      case 'mood_first_steps':
        return (stats['totalMoods'] ?? 0) >= 1;
      case 'mood_warrior':
        return (stats['moodStreak'] ?? 0) >= 7;
      case 'mood_emotional_intelligence':
        return (stats['totalMoods'] ?? 0) >= 30;
      case 'mood_master':
        return (stats['totalMoods'] ?? 0) >= 100;
      case 'mood_consistency_champion':
        return (stats['moodStreak'] ?? 0) >= 30;
      case 'mood_positive_vibes':
        return (stats['positiveMoods'] ?? 0) >= 10;

      // Journal achievements
      case 'journal_pen_to_paper':
        return (stats['totalJournals'] ?? 0) >= 1;
      case 'journal_reflective_soul':
        return (stats['totalJournals'] ?? 0) >= 10;
      case 'journal_storyteller':
        return (stats['totalJournals'] ?? 0) >= 50;
      case 'journal_author':
        return (stats['totalJournals'] ?? 0) >= 100;
      case 'journal_deep_thinker':
        return (stats['longJournals'] ?? 0) >= 1;
      case 'journal_weekly_reflection':
        return (stats['journalStreak'] ?? 0) >= 7;
      case 'journal_monthly_chronicler':
        return (stats['journalStreak'] ?? 0) >= 30;

      // Chat achievements
      case 'chat_hello_mindhaven':
        return (stats['totalChats'] ?? 0) >= 1;
      case 'chat_opening_up':
        return (stats['totalChats'] ?? 0) >= 10;
      case 'chat_trusted_companion':
        return (stats['totalChats'] ?? 0) >= 50;
      case 'chat_deep_connection':
        return (stats['totalChats'] ?? 0) >= 100;
      case 'chat_marathon_talker':
        return (stats['longestChatSession'] ?? 0) >= 30;
      case 'chat_weekly_checkin':
        return (stats['weeklyChats'] ?? 0) >= 4;

      // Wellness achievements
      case 'wellness_explorer':
        return (stats['sectionsVisited'] ?? 0) >= 5;
      case 'wellness_resource_seeker':
        return (stats['resourcesViewed'] ?? 0) >= 1;
      case 'wellness_balanced_life':
        return (stats['balancedWeeks'] ?? 0) >= 1;
      case 'wellness_streak':
        return (stats['overallStreak'] ?? 0) >= 14;
      case 'wellness_champion':
        return (stats['currentLevel'] ?? 1) >= 10;

      // Streak achievements
      case 'streak_3_days':
        return (stats['highestStreak'] ?? 0) >= 3;
      case 'streak_7_days':
        return (stats['highestStreak'] ?? 0) >= 7;
      case 'streak_30_days':
        return (stats['highestStreak'] ?? 0) >= 30;
      case 'streak_60_days':
        return (stats['highestStreak'] ?? 0) >= 60;
      case 'streak_100_days':
        return (stats['highestStreak'] ?? 0) >= 100;

      // Special achievements
      case 'special_early_bird':
        return stats['usedEarlyMorning'] == true;
      case 'special_night_owl':
        return stats['usedLateNight'] == true;
      case 'special_weekend_warrior':
        return stats['usedBothWeekendDays'] == true;
      case 'special_midnight_warrior':
        return stats['usedAtMidnight'] == true;

      default:
        return false;
    }
  }

  int _calculateProgress(Achievement achievement, Map<String, dynamic> stats) {
    switch (achievement.category) {
      case AchievementCategory.mood:
        if (achievement.id.contains('streak')) {
          return stats['moodStreak'] ?? 0;
        }
        return stats['totalMoods'] ?? 0;
      
      case AchievementCategory.journal:
        if (achievement.id.contains('streak')) {
          return stats['journalStreak'] ?? 0;
        }
        return stats['totalJournals'] ?? 0;
      
      case AchievementCategory.chat:
        return stats['totalChats'] ?? 0;
      
      case AchievementCategory.streak:
        return stats['highestStreak'] ?? 0;
      
      default:
        return 0;
    }
  }

  Future<void> unlockAchievement(String userId, Achievement achievement) async {
    final achievementRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievement.id);

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      progress: achievement.target,
    );

    await achievementRef.set(unlockedAchievement.toMap());

    // Award points
    await _pointsService.awardPoints(
      userId: userId,
      basePoints: achievement.points,
      action: 'achievement_unlocked',
      category: 'achievement',
      description: 'Unlocked: ${achievement.name}',
      relatedId: achievement.id,
    );
  }

  Future<void> updateAchievementProgress(String userId, String achievementId, int progress) async {
    final achievementRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievementId);

    final doc = await achievementRef.get();
    if (doc.exists) {
      await achievementRef.update({'progress': progress});
    } else {
      // Create achievement with progress
      final definition = AchievementDefinitions.allDefinitions
          .firstWhere((a) => a.id == achievementId);
      final achievement = definition.copyWith(progress: progress);
      await achievementRef.set(achievement.toMap());
    }
  }

  Future<Achievement?> getAchievement(String userId, String achievementId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (doc.exists) {
        return Achievement.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting achievement: $e');
      return null;
    }
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  Stream<List<Achievement>> getUserAchievementsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromMap(doc.data()))
            .toList());
  }

  Future<int> getUnlockedAchievementsCount(String userId) async {
    final achievements = await getUserAchievements(userId);
    return achievements.where((a) => a.isUnlocked).length;
  }
}
