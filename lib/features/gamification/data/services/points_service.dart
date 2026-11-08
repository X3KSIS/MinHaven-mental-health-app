import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/points_transaction.dart';
import '../models/user_gamification_profile.dart';
import '../../utils/gamification_constants.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  Future<void> awardPoints({
    required String userId,
    required int basePoints,
    required String action,
    required String category,
    String? description,
    String? relatedId,
    int currentStreak = 0,
  }) async {
    // Calculate bonus multipliers
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

    final finalPoints = (basePoints * multiplier).round();

    // Create transaction
    final transaction = PointsTransaction(
      id: _uuid.v4(),
      userId: userId,
      points: finalPoints,
      action: action,
      category: category,
      timestamp: now,
      description: description ?? action,
      relatedId: relatedId,
    );

    // Save transaction
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('points_history')
        .doc(transaction.id)
        .set(transaction.toMap());

    // Update user profile
    await _updateUserProfile(userId, finalPoints, category);
  }

  Future<void> _updateUserProfile(String userId, int points, String category) async {
    final profileRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('gamification')
        .doc('profile');

    await _firestore.runTransaction((transaction) async {
      final profileDoc = await transaction.get(profileRef);
      
      UserGamificationProfile profile;
      if (profileDoc.exists) {
        profile = UserGamificationProfile.fromMap(profileDoc.data()!);
      } else {
        profile = UserGamificationProfile.initial(userId);
      }

      // Update points
      final newTotalPoints = profile.totalPoints + points;
      final newLevel = UserGamificationProfile.calculateLevel(newTotalPoints);
      final newLevelProgress = UserGamificationProfile.calculateLevelProgress(
        newTotalPoints, 
        newLevel
      );

      // Update category points
      final categoryPoints = Map<String, int>.from(profile.categoryPoints);
      categoryPoints[category] = (categoryPoints[category] ?? 0) + points;

      final updatedProfile = profile.copyWith(
        totalPoints: newTotalPoints,
        currentLevel: newLevel,
        levelProgress: newLevelProgress,
        lastActivityDate: DateTime.now(),
        categoryPoints: categoryPoints,
      );

      transaction.set(profileRef, updatedProfile.toMap());
    });
  }

  Future<UserGamificationProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification_profile')
          .doc('profile')
          .get();

      if (doc.exists) {
        return UserGamificationProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Stream<UserGamificationProfile> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('gamification')
        .doc('profile')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserGamificationProfile.fromMap(doc.data()!);
      }
      return UserGamificationProfile.initial(userId);
    });
  }

  Future<List<PointsTransaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('points_history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PointsTransaction.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recent transactions: $e');
      return [];
    }
  }

  Future<void> initializeUserProfile(String userId) async {
    final profileRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('gamification_profile')
        .doc('profile');

    final doc = await profileRef.get();
    if (!doc.exists) {
      final profile = UserGamificationProfile.initial(userId);
      await profileRef.set(profile.toMap());
    }
  }
}
