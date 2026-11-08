class GamificationConstants {
  // Points for base actions
  static const int pointsForMoodLog = 5;
  static const int pointsForJournalEntry = 10;
  static const int pointsForChatMessage = 5;
  static const int pointsForResourceView = 3;
  static const int pointsForProfileUpdate = 2;

  // Bonus multipliers
  static const double streakBonusPerDay = 0.10; // 10% per consecutive day
  static const double maxStreakBonus = 0.50; // Max 50% bonus
  static const double weekendBonus = 0.25; // 25% bonus
  static const double lateNightBonus = 0.20; // 20% bonus (10pm-6am)
  static const double earlyMorningBonus = 0.15; // 15% bonus (5am-8am)
  static const double consistencyBonus = 0.50; // 50% if all features used in a day

  // Streak milestones
  static const List<int> streakMilestones = [3, 7, 14, 30, 60, 90, 180, 365];

  // Time thresholds
  static const int earlyMorningStartHour = 5;
  static const int earlyMorningEndHour = 8;
  static const int lateNightStartHour = 22;
  static const int lateNightEndHour = 6;
  static const int morningChallengeEndHour = 10;
  static const int eveningChallengeStartHour = 18;

  // Challenge limits
  static const int maxDailyChallenges = 5;
  static const int maxWeeklyChallenges = 5;
  static const int maxMonthlyChallenges = 5;

  // Notification settings
  static const bool showPointsNotifications = true;
  static const bool showAchievementNotifications = true;
  static const bool showLevelUpNotifications = true;
  static const bool showStreakNotifications = true;
  static const bool showChallengeNotifications = true;

  // Journal word count for achievements
  static const int deepThinkerWordCount = 500;

  // Chat message count for achievements
  static const int marathonTalkerMessageCount = 30;

  // Feature tracking for wellness explorer
  static const List<String> appSections = [
    'home',
    'mood',
    'journal',
    'chat',
    'profile',
  ];
}
