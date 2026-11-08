import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../models/streak_model.dart';
import '../models/user_gamification_profile.dart';
import '../../utils/gamification_constants.dart';
import 'achievement_service.dart';
import 'challenge_service.dart';
import 'points_service.dart';
import 'streak_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PointsService _pointsService = PointsService();
  final StreakService _streakService = StreakService();
  final AchievementService _achievementService = AchievementService();
  final ChallengeService _challengeService = ChallengeService();

  bool _notificationsEnabled = true;
  int? _previousLevel;

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  Future<void> initializeUser(String userId) async {
    await _pointsService.initializeUserProfile(userId);
    await _challengeService.initializeChallenges(userId);
    
    // Process existing data retroactively
    await processExistingData(userId);
  }

  /// Process existing mood logs, journal entries, and chat messages
  /// to award points and update achievements retroactively
  Future<void> processExistingData(String userId) async {
    try {
      // Check if already processed
      final processedDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification_meta')
          .doc('processed')
          .get();

      if (processedDoc.exists && processedDoc.data()?['retroactiveProcessed'] == true) {
        print('Existing data already processed for user $userId');
        return;
      }

      print('Processing existing data for user $userId...');

      // Process existing mood logs
      await _processExistingMoods(userId);

      // Process existing journal entries
      await _processExistingJournals(userId);

      // Process existing chat messages
      await _processExistingChats(userId);

      // Mark as processed
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification_meta')
          .doc('processed')
          .set({
        'retroactiveProcessed': true,
        'processedAt': DateTime.now(),
      });

      // Check and unlock achievements based on processed data
      await _checkAllAchievements(userId);

      // Show completion notification
      if (_notificationsEnabled) {
        Fluttertoast.showToast(
          msg: "🎉 Gamification initialized with your existing data!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }

      print('Finished processing existing data for user $userId');
    } catch (e) {
      print('Error processing existing data: $e');
    }
  }

  /// Manually reprocess existing data (for testing or data recovery)
  Future<void> reprocessExistingData(String userId) async {
    // Remove the processed flag
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('gamification_meta')
        .doc('processed')
        .delete();

    // Run the processing again
    await processExistingData(userId);
  }

  Future<void> _checkAllAchievements(String userId) async {
    try {
      final stats = await _getUserStats(userId);
      
      // Check and unlock all achievements
      await _achievementService.checkAndUnlockAchievements(
        userId,
        'retroactive_processing',
        stats,
      );
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  Future<void> _processExistingMoods(String userId) async {
    try {
      final moodSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .orderBy('timestamp', descending: false)
          .get();

      print('Processing ${moodSnapshot.docs.length} existing mood logs...');

      for (final doc in moodSnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        // Award points for each mood log
        await _pointsService.awardPoints(
          userId: userId,
          basePoints: 5,
          action: 'mood_logged',
          category: 'mood',
          description: 'Retroactive: Mood logged',
        );
      }

      // Update mood streak based on historical data
      if (moodSnapshot.docs.isNotEmpty) {
        await _streakService.updateStreak(userId, StreakType.mood);
      }

      print('Processed ${moodSnapshot.docs.length} mood logs');
    } catch (e) {
      print('Error processing existing moods: $e');
    }
  }

  Future<void> _processExistingJournals(String userId) async {
    try {
      final journalSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal')
          .orderBy('createdAt', descending: false)
          .get();

      print('Processing ${journalSnapshot.docs.length} existing journal entries...');

      for (final doc in journalSnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final content = data['content'] as String? ?? '';
        final wordCount = content.split(' ').where((w) => w.isNotEmpty).length;
        
        // Award points for each journal entry
        await _pointsService.awardPoints(
          userId: userId,
          basePoints: 10,
          action: 'journal_entry',
          category: 'journal',
          description: 'Retroactive: Journal entry ($wordCount words)',
        );
      }

      // Update journal streak based on historical data
      if (journalSnapshot.docs.isNotEmpty) {
        await _streakService.updateStreak(userId, StreakType.journal);
      }

      print('Processed ${journalSnapshot.docs.length} journal entries');
    } catch (e) {
      print('Error processing existing journals: $e');
    }
  }

  Future<void> _processExistingChats(String userId) async {
    try {
      final chatSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .get();

      int totalMessages = 0;

      for (final chatDoc in chatSnapshot.docs) {
        final messagesSnapshot = await chatDoc.reference
            .collection('messages')
            .where('isUser', isEqualTo: true)
            .orderBy('timestamp', descending: false)
            .get();

        totalMessages += messagesSnapshot.docs.length;

        for (final msgDoc in messagesSnapshot.docs) {
          final data = msgDoc.data();
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
          
          // Award points for each chat message
          await _pointsService.awardPoints(
            userId: userId,
            basePoints: 5,
            action: 'chat_message',
            category: 'chat',
            description: 'Retroactive: Chat message',
          );
        }
      }

      // Update chat streak based on historical data
      if (totalMessages > 0) {
        await _streakService.updateStreak(userId, StreakType.chat);
      }

      print('Processed $totalMessages chat messages from ${chatSnapshot.docs.length} chats');
    } catch (e) {
      print('Error processing existing chats: $e');
    }
  }

  Future<void> trackMoodLogged({String? moodType}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get current streak
      final moodStreak = await _streakService.getStreak(userId, StreakType.mood);
      final currentStreak = moodStreak?.currentStreak ?? 0;

      // Award points
      await _pointsService.awardPoints(
        userId: userId,
        basePoints: GamificationConstants.pointsForMoodLog,
        action: 'mood_logged',
        category: 'mood',
        description: 'Logged mood',
        currentStreak: currentStreak,
      );

      // Update streaks
      await _streakService.updateStreak(userId, StreakType.mood);
      await _streakService.updateStreak(userId, StreakType.overall);

      // Get updated streak
      final updatedStreak = await _streakService.getStreak(userId, StreakType.mood);
      
      // Check for streak milestones
      if (updatedStreak != null && _streakService.isStreakMilestone(updatedStreak.currentStreak)) {
        _showStreakNotification(updatedStreak.currentStreak);
      }

      // Get stats for achievements
      final stats = await _getUserStats(userId);
      
      // Check achievements
      await _achievementService.checkAndUnlockAchievements(userId, 'mood_logged', stats);

      // Update challenges
      await _challengeService.checkAndUpdateChallenges(userId, 'mood_logged', {});

      // Check for level up
      await _checkLevelUp(userId);

      // Show points notification
      if (_notificationsEnabled) {
        final points = _calculateFinalPoints(
          GamificationConstants.pointsForMoodLog, 
          currentStreak
        );
        _showPointsNotification(points);
      }
    } catch (e) {
      print('Error tracking mood logged: $e');
    }
  }

  Future<void> trackJournalEntry({required int wordCount}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get current streak
      final journalStreak = await _streakService.getStreak(userId, StreakType.journal);
      final currentStreak = journalStreak?.currentStreak ?? 0;

      // Award points
      await _pointsService.awardPoints(
        userId: userId,
        basePoints: GamificationConstants.pointsForJournalEntry,
        action: 'journal_created',
        category: 'journal',
        description: 'Created journal entry',
        currentStreak: currentStreak,
      );

      // Update streaks
      await _streakService.updateStreak(userId, StreakType.journal);
      await _streakService.updateStreak(userId, StreakType.overall);

      // Get updated streak
      final updatedStreak = await _streakService.getStreak(userId, StreakType.journal);
      
      // Check for streak milestones
      if (updatedStreak != null && _streakService.isStreakMilestone(updatedStreak.currentStreak)) {
        _showStreakNotification(updatedStreak.currentStreak);
      }

      // Get stats for achievements
      final stats = await _getUserStats(userId);
      stats['longJournals'] = wordCount >= GamificationConstants.deepThinkerWordCount ? 1 : 0;
      
      // Check achievements
      await _achievementService.checkAndUnlockAchievements(userId, 'journal_created', stats);

      // Update challenges
      await _challengeService.checkAndUpdateChallenges(userId, 'journal_created', {});

      // Check for level up
      await _checkLevelUp(userId);

      // Show points notification
      if (_notificationsEnabled) {
        final points = _calculateFinalPoints(
          GamificationConstants.pointsForJournalEntry, 
          currentStreak
        );
        _showPointsNotification(points);
      }
    } catch (e) {
      print('Error tracking journal entry: $e');
    }
  }

  Future<void> trackChatMessage({required String chatId, required int messageCount}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get current streak
      final chatStreak = await _streakService.getStreak(userId, StreakType.chat);
      final currentStreak = chatStreak?.currentStreak ?? 0;

      // Award points
      await _pointsService.awardPoints(
        userId: userId,
        basePoints: GamificationConstants.pointsForChatMessage,
        action: 'chat_message_sent',
        category: 'chat',
        description: 'Sent chat message',
        relatedId: chatId,
        currentStreak: currentStreak,
      );

      // Update streaks
      await _streakService.updateStreak(userId, StreakType.chat);
      await _streakService.updateStreak(userId, StreakType.overall);

      // Get stats for achievements
      final stats = await _getUserStats(userId);
      stats['longestChatSession'] = messageCount;
      
      // Check achievements
      await _achievementService.checkAndUnlockAchievements(userId, 'chat_message_sent', stats);

      // Update challenges
      await _challengeService.checkAndUpdateChallenges(userId, 'chat_message_sent', {});

      // Check for level up
      await _checkLevelUp(userId);

      // Show points notification (only occasionally to avoid spam)
      if (_notificationsEnabled && messageCount % 5 == 0) {
        final points = _calculateFinalPoints(
          GamificationConstants.pointsForChatMessage, 
          currentStreak
        );
        _showPointsNotification(points);
      }
    } catch (e) {
      print('Error tracking chat message: $e');
    }
  }

  Future<void> trackResourceViewed() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _pointsService.awardPoints(
        userId: userId,
        basePoints: GamificationConstants.pointsForResourceView,
        action: 'resource_viewed',
        category: 'wellness',
        description: 'Viewed mental health resource',
      );

      // Get stats for achievements
      final stats = await _getUserStats(userId);
      
      // Check achievements
      await _achievementService.checkAndUnlockAchievements(userId, 'resource_viewed', stats);
    } catch (e) {
      print('Error tracking resource viewed: $e');
    }
  }

  Future<void> trackSectionVisited(String section) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Track visited sections
      final visitedRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification')
          .doc('visited_sections');

      await visitedRef.set({
        section: DateTime.now(),
      }, SetOptions(merge: true));

      // Get stats for achievements
      final stats = await _getUserStats(userId);
      
      // Check achievements
      await _achievementService.checkAndUnlockAchievements(userId, 'section_visited', stats);

      // Check special time-based achievements
      await _checkSpecialAchievements(userId);
    } catch (e) {
      print('Error tracking section visited: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserStats(String userId) async {
    final stats = <String, dynamic>{};

    // Get mood stats
    final moodSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('moods')
        .get();
    stats['totalMoods'] = moodSnapshot.docs.length;

    // Get journal stats
    final journalSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .get();
    stats['totalJournals'] = journalSnapshot.docs.length;

    // Get chat stats
    final chatSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .get();
    stats['totalChats'] = chatSnapshot.docs.length;

    // Get streaks
    final moodStreak = await _streakService.getStreak(userId, StreakType.mood);
    final journalStreak = await _streakService.getStreak(userId, StreakType.journal);
    final chatStreak = await _streakService.getStreak(userId, StreakType.chat);
    final overallStreak = await _streakService.getStreak(userId, StreakType.overall);

    stats['moodStreak'] = moodStreak?.currentStreak ?? 0;
    stats['journalStreak'] = journalStreak?.currentStreak ?? 0;
    stats['chatStreak'] = chatStreak?.currentStreak ?? 0;
    stats['overallStreak'] = overallStreak?.currentStreak ?? 0;
    stats['highestStreak'] = await _streakService.getHighestCurrentStreak(userId);

    // Get profile
    final profile = await _pointsService.getUserProfile(userId);
    stats['currentLevel'] = profile?.currentLevel ?? 1;

    // Get visited sections
    final visitedDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('gamification')
        .doc('visited_sections')
        .get();
    stats['sectionsVisited'] = visitedDoc.exists ? visitedDoc.data()!.length : 0;

    return stats;
  }

  Future<void> _checkSpecialAchievements(String userId) async {
    final now = DateTime.now();
    final hour = now.hour;
    final stats = <String, dynamic>{};

    // Early bird (5am-8am)
    if (hour >= GamificationConstants.earlyMorningStartHour && 
        hour < GamificationConstants.earlyMorningEndHour) {
      stats['usedEarlyMorning'] = true;
    }

    // Night owl (10pm-6am)
    if (hour >= GamificationConstants.lateNightStartHour || 
        hour < GamificationConstants.lateNightEndHour) {
      stats['usedLateNight'] = true;
    }

    // Midnight warrior (exactly midnight)
    if (hour == 0 && now.minute < 5) {
      stats['usedAtMidnight'] = true;
    }

    // Weekend warrior
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      final weekendRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification')
          .doc('weekend_tracking');
      
      final weekendDoc = await weekendRef.get();
      if (weekendDoc.exists) {
        final data = weekendDoc.data()!;
        final saturdayUsed = data['saturday'] ?? false;
        final sundayUsed = data['sunday'] ?? false;
        
        if (now.weekday == DateTime.saturday) {
          await weekendRef.set({'saturday': true}, SetOptions(merge: true));
        } else {
          await weekendRef.set({'sunday': true}, SetOptions(merge: true));
        }
        
        if (saturdayUsed && sundayUsed) {
          stats['usedBothWeekendDays'] = true;
        }
      } else {
        await weekendRef.set({
          now.weekday == DateTime.saturday ? 'saturday' : 'sunday': true,
        });
      }
    }

    if (stats.isNotEmpty) {
      await _achievementService.checkAndUnlockAchievements(userId, 'special', stats);
    }
  }

  Future<void> _checkLevelUp(String userId) async {
    final profile = await _pointsService.getUserProfile(userId);
    if (profile == null) return;

    if (_previousLevel == null) {
      _previousLevel = profile.currentLevel;
      return;
    }

    if (profile.currentLevel > _previousLevel!) {
      _showLevelUpNotification(profile.currentLevel, profile.levelTitle);
      _previousLevel = profile.currentLevel;
    }
  }

  int _calculateFinalPoints(int basePoints, int currentStreak) {
    final now = DateTime.now();
    double multiplier = 1.0;

    // Streak bonus
    if (currentStreak > 0) {
      final streakBonus = (currentStreak * GamificationConstants.streakBonusPerDay)
          .clamp(0.0, GamificationConstants.maxStreakBonus);
      multiplier += streakBonus;
    }

    // Time-based bonuses
    final hour = now.hour;
    if (hour >= GamificationConstants.earlyMorningStartHour && 
        hour < GamificationConstants.earlyMorningEndHour) {
      multiplier += GamificationConstants.earlyMorningBonus;
    }
    if (hour >= GamificationConstants.lateNightStartHour || 
        hour < GamificationConstants.lateNightEndHour) {
      multiplier += GamificationConstants.lateNightBonus;
    }

    // Weekend bonus
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      multiplier += GamificationConstants.weekendBonus;
    }

    return (basePoints * multiplier).round();
  }

  void _showPointsNotification(int points) {
    if (!_notificationsEnabled) return;
    
    Fluttertoast.showToast(
      msg: "+$points points",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green[700],
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showStreakNotification(int days) {
    if (!_notificationsEnabled) return;
    
    Fluttertoast.showToast(
      msg: "🔥 $days-day streak!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange[700],
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showLevelUpNotification(int level, String title) {
    if (!_notificationsEnabled) return;
    
    Fluttertoast.showToast(
      msg: "⭐ Level $level: $title!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.purple[700],
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }

  void showAchievementUnlocked(String name, String emoji) {
    if (!_notificationsEnabled) return;
    
    Fluttertoast.showToast(
      msg: "$emoji $name unlocked!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.amber[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showChallengeCompleted(String name, int points) {
    if (!_notificationsEnabled) return;
    
    Fluttertoast.showToast(
      msg: "🎯 $name completed! +$points points",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.blue[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Getters for services
  PointsService get pointsService => _pointsService;
  StreakService get streakService => _streakService;
  AchievementService get achievementService => _achievementService;
  ChallengeService get challengeService => _challengeService;
}
