import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/achievement_model.dart';
import '../../data/services/gamification_service.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final gamificationService = GamificationService();
    final theme = Theme.of(context);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: const Center(child: Text('Please log in to view achievements')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: StreamBuilder<List<Achievement>>(
        stream: gamificationService.achievementService.getUserAchievementsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userAchievements = snapshot.data ?? [];
          final unlockedCount = userAchievements.where((a) => a.isUnlocked).length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                      const SizedBox(height: 16),
                      Text(
                        '$unlockedCount / 33',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Achievements Unlocked',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCategorySection(
                      'Mood Tracking',
                      AchievementCategory.mood,
                      userAchievements,
                      Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    _buildCategorySection(
                      'Journaling',
                      AchievementCategory.journal,
                      userAchievements,
                      Colors.purple,
                    ),
                    const SizedBox(height: 24),
                    _buildCategorySection(
                      'Chat Engagement',
                      AchievementCategory.chat,
                      userAchievements,
                      Colors.green,
                    ),
                    const SizedBox(height: 24),
                    _buildCategorySection(
                      'Wellness',
                      AchievementCategory.wellness,
                      userAchievements,
                      Colors.teal,
                    ),
                    const SizedBox(height: 24),
                    _buildCategorySection(
                      'Streaks',
                      AchievementCategory.streak,
                      userAchievements,
                      Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    _buildCategorySection(
                      'Special',
                      AchievementCategory.special,
                      userAchievements,
                      Colors.pink,
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    AchievementCategory category,
    List<Achievement> userAchievements,
    Color color,
  ) {
    final categoryAchievements = userAchievements
        .where((a) => a.category == category)
        .toList();

    if (categoryAchievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...categoryAchievements.map((achievement) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAchievementCard(achievement, color),
        )),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, Color categoryColor) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progress / achievement.target;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? categoryColor : Colors.grey[300]!,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: categoryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? categoryColor.withOpacity(0.1)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.iconEmoji,
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTierColor(achievement.tier),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          achievement.tier.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (!isUnlocked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${achievement.progress}/${achievement.target}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: categoryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          fontSize: 12,
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${achievement.points} points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.brown;
      case AchievementTier.silver:
        return Colors.grey;
      case AchievementTier.gold:
        return Colors.amber;
      case AchievementTier.platinum:
        return Colors.cyan;
      case AchievementTier.diamond:
        return Colors.blue;
    }
  }
}
