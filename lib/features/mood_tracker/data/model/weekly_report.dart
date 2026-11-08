class WeeklyReport {
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final int totalEntries;
  final String summary;
  final List<String> recommendations;
  final DateTime generatedAt;

  WeeklyReport({
    required this.weekStartDate,
    required this.weekEndDate,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.totalEntries,
    required this.summary,
    required this.recommendations,
    required this.generatedAt,
  });
}