import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../mood_dashboard.dart';
import '../model/mood_entry.dart';
import '../../utils/constants.dart';
import '../model/weekly_report.dart';
import '../../../gamification/data/services/gamification_service.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GamificationService _gamificationService = GamificationService();

  Stream<List<MoodEntryData>> getMoodsStream(int limit) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return MoodEntryData(
        score: data['score'] as int,
        note: data['note'] as String? ?? '',
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList());
  }

  Future<void> logMood(int score, String note) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .add({
      'score': score,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Track gamification
    await _gamificationService.trackMoodLogged();
  }

  Future<bool> canLogMood() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final now = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (snapshot.docs.length >= MoodConstants.maxMoodsPerDay) {
        return false;
      }

      final lastSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastSnapshot.docs.isNotEmpty) {
        final lastMoodTime = (lastSnapshot.docs.first.data()['timestamp'] as Timestamp).toDate();
        final hoursSinceLast = now.difference(lastMoodTime).inHours;
        if (hoursSinceLast < MoodConstants.minHoursBetweenMoods) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<MoodEntryData>> getMoodsForWeek(DateTime weekStart, DateTime weekEnd) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(weekEnd))
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MoodEntryData(
        score: data['score'] as int,
        note: data['note'] as String? ?? '',
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<void> saveWeeklyReport(WeeklyReport report) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection(MoodConstants.weeklyReportCollection)
        .add({
      'weekStartDate': Timestamp.fromDate(report.weekStartDate),
      'weekEndDate': Timestamp.fromDate(report.weekEndDate),
      'averageScore': report.averageScore,
      'highestScore': report.highestScore,
      'lowestScore': report.lowestScore,
      'totalEntries': report.totalEntries,
      'summary': report.summary,
      'recommendations': report.recommendations,
      'generatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<WeeklyReport?> getLatestWeeklyReport() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(MoodConstants.weeklyReportCollection)
          .orderBy('weekEndDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        return WeeklyReport(
          weekStartDate: (data['weekStartDate'] as Timestamp).toDate(),
          weekEndDate: (data['weekEndDate'] as Timestamp).toDate(),
          averageScore: data['averageScore'] as double,
          highestScore: data['highestScore'] as int,
          lowestScore: data['lowestScore'] as int,
          totalEntries: data['totalEntries'] as int,
          summary: data['summary'] as String,
          recommendations: List<String>.from(data['recommendations'] as List),
          generatedAt: (data['generatedAt'] as Timestamp).toDate(),
        );
      }
    } catch (e) {
      // Silently fail - reports are optional
    }
    return null;
  }
}