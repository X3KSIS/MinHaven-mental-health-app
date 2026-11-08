import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import '../../utils/challenge_definitions.dart';
import 'points_service.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointsService _pointsService = PointsService();

  Future<void> initializeChallenges(String userId) async {
    final now = DateTime.now();
    
    // Initialize daily challenges
    await _initializeDailyChallenges(userId, now);
    
    // Initialize weekly challenges
    await _initializeWeeklyChallenges(userId, now);
    
    // Initialize monthly challenges
    await _initializeMonthlyChallenges(userId, now);
    
    // Initialize milestone challenges
    await _initializeMilestoneChallenges(userId);
  }

  Future<void> _initializeDailyChallenges(String userId, DateTime date) async {
    final challenges = ChallengeDefinitions.getDailyChallenges(date);
    
    for (final challenge in challenges) {
      final challengeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challenge.id);

      final doc = await challengeRef.get();
      if (!doc.exists) {
        await challengeRef.set(challenge.toMap());
      }
    }
  }

  Future<void> _initializeWeeklyChallenges(String userId, DateTime date) async {
    final weekStart = _getWeekStart(date);
    final challenges = ChallengeDefinitions.getWeeklyChallenges(weekStart);
    
    for (final challenge in challenges) {
      final challengeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challenge.id);

      final doc = await challengeRef.get();
      if (!doc.exists) {
        await challengeRef.set(challenge.toMap());
      }
    }
  }

  Future<void> _initializeMonthlyChallenges(String userId, DateTime date) async {
    final monthStart = DateTime(date.year, date.month, 1);
    final challenges = ChallengeDefinitions.getMonthlyChallenges(monthStart);
    
    for (final challenge in challenges) {
      final challengeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challenge.id);

      final doc = await challengeRef.get();
      if (!doc.exists) {
        await challengeRef.set(challenge.toMap());
      }
    }
  }

  Future<void> _initializeMilestoneChallenges(String userId) async {
    final challenges = ChallengeDefinitions.getMilestoneChallenges();
    
    for (final challenge in challenges) {
      final challengeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challenge.id);

      final doc = await challengeRef.get();
      if (!doc.exists) {
        await challengeRef.set(challenge.toMap());
      }
    }
  }

  Future<void> updateChallengeProgress(String userId, String challengeId, int increment) async {
    final challengeRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .doc(challengeId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(challengeRef);
      
      if (!doc.exists) return;
      
      final challenge = Challenge.fromMap(doc.data()!);
      
      if (challenge.isCompleted || challenge.isExpired) return;
      
      final newProgress = challenge.progress + increment;
      final isCompleted = newProgress >= challenge.target;
      
      transaction.update(challengeRef, {
        'progress': newProgress,
        'isCompleted': isCompleted,
      });
      
      if (isCompleted) {
        // Award points
        await _pointsService.awardPoints(
          userId: userId,
          basePoints: challenge.points,
          action: 'challenge_completed',
          category: 'challenge',
          description: 'Completed: ${challenge.name}',
          relatedId: challenge.id,
        );
      }
    });
  }

  Future<List<Challenge>> getActiveChallenges(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: now)
          .get();

      return snapshot.docs
          .map((doc) => Challenge.fromMap(doc.data()))
          .where((c) => !c.isCompleted)
          .toList();
    } catch (e) {
      print('Error getting active challenges: $e');
      return [];
    }
  }

  Stream<List<Challenge>> getActiveChallengesStream(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: now)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Challenge.fromMap(doc.data()))
            .where((c) => !c.isCompleted)
            .toList());
  }

  Future<List<Challenge>> getCompletedChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .where('isCompleted', isEqualTo: true)
          .orderBy('endDate', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Challenge.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting completed challenges: $e');
      return [];
    }
  }

  Future<void> checkAndUpdateChallenges(String userId, String action, Map<String, dynamic> data) async {
    final challenges = await getActiveChallenges(userId);
    
    for (final challenge in challenges) {
      bool shouldUpdate = false;
      
      switch (action) {
        case 'mood_logged':
          if (challenge.category == ChallengeCategory.mood) {
            shouldUpdate = true;
          }
          break;
        case 'journal_created':
          if (challenge.category == ChallengeCategory.journal) {
            shouldUpdate = true;
          }
          break;
        case 'chat_message_sent':
          if (challenge.category == ChallengeCategory.chat) {
            shouldUpdate = true;
          }
          break;
        case 'app_used':
          if (challenge.category == ChallengeCategory.wellness) {
            shouldUpdate = true;
          }
          break;
      }
      
      if (shouldUpdate) {
        await updateChallengeProgress(userId, challenge.id, 1);
      }
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  Future<void> cleanupExpiredChallenges(String userId) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .where('endDate', isLessThan: now)
        .where('isCompleted', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isActive': false});
    }
  }
}
