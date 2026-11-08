import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getSettings() async {
    final user = _auth.currentUser;
    if (user == null) return _getDefaultSettings();
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .get();
      if (doc.exists) {
        return doc.data() ?? _getDefaultSettings();
      }
      return _getDefaultSettings();
    } catch (e) {
      print('Error getting settings: $e');
      return _getDefaultSettings();
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('preferences')
        .set(settings, SetOptions(merge: true));
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'notifications': true,
      'dailyReminders': true,
      'soundEffects': true,
      'darkMode': false,
      'dataBackup': true,
      'shareAnalytics': false,
    };
  }

  Stream<Map<String, dynamic>> getSettingsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(_getDefaultSettings());
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .map((doc) => doc.exists ? doc.data()! : _getDefaultSettings());
  }
}