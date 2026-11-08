import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/challenge_model.dart';
import '../../data/services/gamification_service.dart';

class ChallengesWidget extends StatelessWidget {
  const ChallengesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final gamificationService = GamificationService();

    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<Challenge>>(
      stream: gamificationService.challengeService.getActiveChallengesStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final challenges = snapshot.data!;
        final dailyChallenges = challenges.where((c) => c.type == ChallengeType.daily).toList();
        final weeklyChallenges = challenges.where((c) => c.type == ChallengeType.weekly).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Challenges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (dailyChallenges.isNotEmpty) ...[
              _buildChallengeSection('Daily Challenges', dailyChallenges, Colors.orange),
              const SizedBox(height: 16),
            ],
            if (weeklyChallenges.isNotEmpty) ...[
              _buildChallengeSection('Weekly Challenges', weeklyChallenges, Colors.purple),
            ],
          ],
        );
      },
    );
  }

  Widget _buildChallengeSection(String title, List<Challenge> challenges, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...challenges.take(3).map((challenge) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChallengeCard(challenge, color),
        )),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge, Color color) {
    final progress = challenge.progress / challenge.target;
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                challenge.iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.points}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${challenge.progress}/${challenge.target}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(height: 2),
                  Text(
                    '$daysLeft day${daysLeft != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
