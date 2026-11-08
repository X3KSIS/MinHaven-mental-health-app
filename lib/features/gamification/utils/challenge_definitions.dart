import '../data/models/challenge_model.dart';

class ChallengeDefinitions {
  static List<Challenge> getDailyChallenges(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return [
      Challenge(
        id: 'daily_morning_mood_${date.toIso8601String().split('T')[0]}',
        name: 'Morning Mood Check',
        description: 'Log your mood before 10am',
        type: ChallengeType.daily,
        category: ChallengeCategory.mood,
        points: 20,
        target: 1,
        startDate: startOfDay,
        endDate: endOfDay,
        iconEmoji: '🌅',
      ),
      Challenge(
        id: 'daily_evening_reflection_${date.toIso8601String().split('T')[0]}',
        name: 'Evening Reflection',
        description: 'Write a journal entry after 6pm',
        type: ChallengeType.daily,
        category: ChallengeCategory.journal,
        points: 25,
        target: 1,
        startDate: startOfDay,
        endDate: endOfDay,
        iconEmoji: '🌆',
      ),
      Challenge(
        id: 'daily_chat_session_${date.toIso8601String().split('T')[0]}',
        name: 'Chat Session',
        description: 'Have a conversation with MindHaven',
        type: ChallengeType.daily,
        category: ChallengeCategory.chat,
        points: 15,
        target: 1,
        startDate: startOfDay,
        endDate: endOfDay,
        iconEmoji: '💬',
      ),
      Challenge(
        id: 'daily_gratitude_${date.toIso8601String().split('T')[0]}',
        name: 'Gratitude Practice',
        description: 'Journal about things you\'re grateful for',
        type: ChallengeType.daily,
        category: ChallengeCategory.journal,
        points: 30,
        target: 1,
        startDate: startOfDay,
        endDate: endOfDay,
        iconEmoji: '🙏',
      ),
      Challenge(
        id: 'daily_mood_diversity_${date.toIso8601String().split('T')[0]}',
        name: 'Mood Diversity',
        description: 'Log 3 moods throughout the day',
        type: ChallengeType.daily,
        category: ChallengeCategory.mood,
        points: 25,
        target: 3,
        startDate: startOfDay,
        endDate: endOfDay,
        iconEmoji: '🎨',
      ),
    ];
  }

  static List<Challenge> getWeeklyChallenges(DateTime weekStart) {
    final endOfWeek = weekStart.add(const Duration(days: 7));

    return [
      Challenge(
        id: 'weekly_consistent_logger_${weekStart.toIso8601String().split('T')[0]}',
        name: 'Consistent Logger',
        description: 'Log mood 5 out of 7 days',
        type: ChallengeType.weekly,
        category: ChallengeCategory.mood,
        points: 100,
        target: 5,
        startDate: weekStart,
        endDate: endOfWeek,
        iconEmoji: '📊',
      ),
      Challenge(
        id: 'weekly_journal_journey_${weekStart.toIso8601String().split('T')[0]}',
        name: 'Journal Journey',
        description: 'Write 3 journal entries this week',
        type: ChallengeType.weekly,
        category: ChallengeCategory.journal,
        points: 75,
        target: 3,
        startDate: weekStart,
        endDate: endOfWeek,
        iconEmoji: '📝',
      ),
      Challenge(
        id: 'weekly_active_engagement_${weekStart.toIso8601String().split('T')[0]}',
        name: 'Active Engagement',
        description: 'Use app 5 days this week',
        type: ChallengeType.weekly,
        category: ChallengeCategory.wellness,
        points: 125,
        target: 5,
        startDate: weekStart,
        endDate: endOfWeek,
        iconEmoji: '🎯',
      ),
      Challenge(
        id: 'weekly_wellness_warrior_${weekStart.toIso8601String().split('T')[0]}',
        name: 'Wellness Warrior',
        description: 'Complete 5 daily challenges',
        type: ChallengeType.weekly,
        category: ChallengeCategory.wellness,
        points: 150,
        target: 5,
        startDate: weekStart,
        endDate: endOfWeek,
        iconEmoji: '⚔️',
      ),
      Challenge(
        id: 'weekly_balanced_week_${weekStart.toIso8601String().split('T')[0]}',
        name: 'Balanced Week',
        description: 'Use all features at least once',
        type: ChallengeType.weekly,
        category: ChallengeCategory.mixed,
        points: 100,
        target: 1,
        startDate: weekStart,
        endDate: endOfWeek,
        iconEmoji: '⚖️',
      ),
    ];
  }

  static List<Challenge> getMonthlyChallenges(DateTime monthStart) {
    final endOfMonth = DateTime(monthStart.year, monthStart.month + 1, 1);

    return [
      Challenge(
        id: 'monthly_30_day_commitment_${monthStart.toIso8601String().split('T')[0]}',
        name: '30-Day Commitment',
        description: 'Use app 25 out of 30 days',
        type: ChallengeType.monthly,
        category: ChallengeCategory.wellness,
        points: 500,
        target: 25,
        startDate: monthStart,
        endDate: endOfMonth,
        iconEmoji: '📅',
      ),
      Challenge(
        id: 'monthly_mood_master_${monthStart.toIso8601String().split('T')[0]}',
        name: 'Mood Master Month',
        description: 'Log mood every day this month',
        type: ChallengeType.monthly,
        category: ChallengeCategory.mood,
        points: 750,
        target: 30,
        startDate: monthStart,
        endDate: endOfMonth,
        iconEmoji: '👑',
      ),
      Challenge(
        id: 'monthly_journaling_journey_${monthStart.toIso8601String().split('T')[0]}',
        name: 'Journaling Journey',
        description: 'Write 15 journal entries',
        type: ChallengeType.monthly,
        category: ChallengeCategory.journal,
        points: 400,
        target: 15,
        startDate: monthStart,
        endDate: endOfMonth,
        iconEmoji: '📚',
      ),
      Challenge(
        id: 'monthly_conversation_champion_${monthStart.toIso8601String().split('T')[0]}',
        name: 'Conversation Champion',
        description: 'Have 20 chat sessions',
        type: ChallengeType.monthly,
        category: ChallengeCategory.chat,
        points: 350,
        target: 20,
        startDate: monthStart,
        endDate: endOfMonth,
        iconEmoji: '🗣️',
      ),
      Challenge(
        id: 'monthly_wellness_month_${monthStart.toIso8601String().split('T')[0]}',
        name: 'Wellness Month',
        description: 'Complete 20 daily challenges',
        type: ChallengeType.monthly,
        category: ChallengeCategory.wellness,
        points: 600,
        target: 20,
        startDate: monthStart,
        endDate: endOfMonth,
        iconEmoji: '🌟',
      ),
    ];
  }

  static List<Challenge> getMilestoneChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: 'milestone_first_week',
        name: 'First Week',
        description: 'Use app for 7 consecutive days',
        type: ChallengeType.milestone,
        category: ChallengeCategory.wellness,
        points: 100,
        target: 7,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
        iconEmoji: '🎯',
      ),
      Challenge(
        id: 'milestone_first_month',
        name: 'First Month',
        description: 'Use app for 30 consecutive days',
        type: ChallengeType.milestone,
        category: ChallengeCategory.wellness,
        points: 300,
        target: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
        iconEmoji: '🏅',
      ),
      Challenge(
        id: 'milestone_100_days_strong',
        name: '100 Days Strong',
        description: 'Use app for 100 days',
        type: ChallengeType.milestone,
        category: ChallengeCategory.wellness,
        points: 1000,
        target: 100,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
        iconEmoji: '💪',
      ),
    ];
  }
}
