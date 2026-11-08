import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeHeaderSection extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String Function() getGreeting;

  const HomeHeaderSection({
    super.key,
    required this.firestore,
    required this.auth,
    required this.getGreeting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final user = auth.currentUser;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: user != null ? firestore.collection('users').doc(user.uid).get() : null,
              builder: (context, snapshot) {
                final userName = snapshot.data?.get('name') ?? 'Friend';
                return Text(
                  '${getGreeting()}, $userName!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Remember: Life is precious. Infinitely so. Perhaps it takes a machine intelligence to appreciate that.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}