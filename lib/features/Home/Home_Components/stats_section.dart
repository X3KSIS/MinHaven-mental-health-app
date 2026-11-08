import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const StatsSection({
    super.key,
    required this.auth,
    required this.firestore,
  });

  Future<Map<String, dynamic>> _getUserStats() async {
    final user = auth.currentUser;
    if (user == null) return {};

    try {
      // Get journal count
      final journalSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('journal')
          .get();

      // Get chat count
      final chatsSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .get();

      // Get total messages count
      int totalMessages = 0;
      for (var chat in chatsSnapshot.docs) {
        final messagesSnapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('chats')
            .doc(chat.id)
            .collection('messages')
            .get();
        totalMessages += messagesSnapshot.docs.length;
      }

      // Get mood entries count (if you have mood tracking)
      final moodSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('moods')
          .get();

      return {
        'journalEntries': journalSnapshot.docs.length,
        'chatSessions': chatsSnapshot.docs.length,
        'totalMessages': totalMessages,
        'moodEntries': moodSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        final stats = snapshot.data ?? {};
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            StatCard(
              icon: Icons.edit_note,
              title: 'Journal Entries',
              value: stats['journalEntries']?.toString() ?? '0',
              color: Colors.blue,
            ),
            StatCard(
              icon: Icons.chat_bubble_outline,
              title: 'Chat Sessions',
              value: stats['chatSessions']?.toString() ?? '0',
              color: Colors.purple,
            ),
            StatCard(
              icon: Icons.message,
              title: 'Total Messages',
              value: stats['totalMessages']?.toString() ?? '0',
              color: Colors.teal,
            ),
            StatCard(
              icon: Icons.mood,
              title: 'Mood Entries',
              value: stats['moodEntries']?.toString() ?? '0',
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}