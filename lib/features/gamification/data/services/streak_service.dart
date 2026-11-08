import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak_model.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateStreak(String userId, StreakType streakType) async {
    final streakRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('streaks')
        .doc(streakType.toString());

    await _firestore.runTransaction((transaction) async {
      final streakDoc = await transaction.get(streakRef);
      final now = DateTime.now();

      if (!streakDoc.exists) {
        // First time - create new streak
        final newStreak = Streak(
          type: streakType,
          currentStreak: 1,
          longestStreak: 1,
          lastActivityDate: now,
          streakStartDate: now,
          totalActiveDays: 1,
        );
        transaction.set(streakRef, newStreak.toMap());
        return;
      }

      final streak = Streak.fromMap(streakDoc.data()!, streakType);
      final lastActivity = streak.lastActivityDate;
      final daysSince = _daysBetween(lastActivity, now);

      if (daysSince == 0) {
        // Same day, no update needed
        return;
      } else if (daysSince == 1) {
        // Consecutive day - increment streak
        final newCurrentStreak = streak.currentStreak + 1;
        final newLongestStreak = max(newCurrentStreak, streak.longestStreak);
        
        final updatedStreak = streak.copyWith(
          currentStreak: newCurrentStreak,
          longestStreak: newLongestStreak,
          lastActivityDate: now,
          totalActiveDays: streak.totalActiveDays + 1,
        );
        
        transaction.update(streakRef, updatedStreak.toMap());
      } else {
        // Streak broken - reset to 1
        final updatedStreak = streak.copyWith(
          currentStreak: 1,
          lastActivityDate: now,
          streakStartDate: now,
          totalActiveDays: streak.totalActiveDays + 1,
        );
        
        transaction.update(streakRef, updatedStreak.toMap());
      }
    });
  }

  Future<Streak?> getStreak(String userId, StreakType streakType) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('streaks')
          .doc(streakType.toString())
          .get();

      if (doc.exists) {
        return Streak.fromMap(doc.data()!, streakType);
      }
      return null;
    } catch (e) {
      print('Error getting streak: $e');
      return null;
    }
  }

  Stream<Streak?> getStreakStream(String userId, StreakType streakType) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('streaks')
        .doc(streakType.toString())
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Streak.fromMap(doc.data()!, streakType);
      }
      return null;
    });
  }

  Future<Map<StreakType, Streak>> getAllStreaks(String userId) async {
    final Map<StreakType, Streak> streaks = {};
    
    for (final type in StreakType.values) {
      final streak = await getStreak(userId, type);
      if (streak != null) {
        streaks[type] = streak;
      }
    }
    
    return streaks;
  }

  Future<int> getHighestCurrentStreak(String userId) async {
    final streaks = await getAllStreaks(userId);
    if (streaks.isEmpty) return 0;
    
    return streaks.values
        .map((s) => s.currentStreak)
        .reduce((a, b) => a > b ? a : b);
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  bool isStreakMilestone(int streakCount) {
    const milestones = [3, 7, 14, 30, 60, 90, 180, 365];
    return milestones.contains(streakCount);
  }
}
