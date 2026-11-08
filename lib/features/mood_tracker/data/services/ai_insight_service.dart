import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import '../../mood_dashboard.dart';
import '../model/mood_entry.dart';
import '../model/weekly_report.dart';


class AIInsightService {
  final GenerativeModel _model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: const String.fromEnvironment("GEMINI_API_KEY"),
  );

  Future<String> generateDailyInsights(List<MoodEntryData> recentMoods) async {
    if (recentMoods.isEmpty) return 'Log your mood to see personalized insights!';

    final moodData = recentMoods.map((m) => 'Score: ${m.score}, Note: "${m.note.isEmpty ? "none" : m.note}"').join(' | ');
    final avgScore = (recentMoods.map((m) => m.score).reduce((a, b) => a + b) / recentMoods.length).toStringAsFixed(1);

    final prompt = '''Analyze this user's mood data using SENTIMENT Analysis and emotional inference from the past week for MindHaven mental wellness app:
$moodData

Average mood score: $avgScore/10

Provide a response in exactly this format:
1. One encouraging sentence about their mood pattern (2-3 lines max)
2. One specific, actionable tip to maintain or improve their mental wellness (2-3 lines max)

Keep the tone warm, empathetic, and positive. Be specific to their data.''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Keep tracking your moods to see personalized insights!';
    } catch (e) {
      return 'Could not generate insights right now. Your mood data shows you\'re making great progress by staying consistent with logging!';
    }
  }

  Future<WeeklyReport> generateWeeklyReport(List<MoodEntryData> weekMoods, DateTime weekStart, DateTime weekEnd) async {
    if (weekMoods.isEmpty) {
      throw Exception('Not enough mood data for weekly report');
    }

    final scores = weekMoods.map((m) => m.score).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final highestScore = scores.reduce((a, b) => a > b ? a : b);
    final lowestScore = scores.reduce((a, b) => a < b ? a : b);

    final moodDetails = weekMoods.map((m) {
      final day = DateFormat('EEEE').format(m.timestamp);
      return '$day: ${m.score}/10 ${m.note.isNotEmpty ? "- ${m.note}" : ""}';
    }).join('\n');

    final prompt = '''Generate a comprehensive weekly mood report for MindHaven user based on this week's data(Implement Sentiment Analysis):

MOOD LOGS:
$moodDetails

STATISTICS:
- Average mood: ${avgScore.toStringAsFixed(1)}/10
- Highest: $highestScore/10
- Lowest: $lowestScore/10
- Total entries: ${weekMoods.length}

Please provide:
1. A 3-4 sentence summary analyzing their overall mood patterns, trends, and any notable observations
2. Exactly 3 specific, actionable recommendations to improve their mental wellness

Format your response as:
SUMMARY: [your summary here]

RECOMMENDATIONS:
1. [First recommendation]
2. [Second recommendation]
3. [Third recommendation]

Keep the tone encouraging, empathetic, and professional. Be specific to their data and patterns.''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final reportText = response.text ?? '';

    final summaryMatch = RegExp(r'SUMMARY:\s*(.+?)(?=RECOMMENDATIONS:|$)', dotAll: true).firstMatch(reportText);
    final recommendationsMatch = RegExp(r'RECOMMENDATIONS:\s*(.+)', dotAll: true).firstMatch(reportText);

    String summary = summaryMatch?.group(1)?.trim() ?? 'Great job tracking your mood this week! Keep up the consistent logging.';
    List<String> recommendations = [];

    if (recommendationsMatch != null) {
      final recsText = recommendationsMatch.group(1)?.trim() ?? '';
      recommendations = recsText
          .split('\n')
          .where((line) => line.trim().isNotEmpty && RegExp(r'^\d+\.').hasMatch(line.trim()))
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
          .take(3)
          .toList();
    }

    if (recommendations.isEmpty) {
      recommendations = [
        'Continue your consistent mood logging to track patterns',
        'Practice mindfulness or meditation for 5-10 minutes daily',
        'Connect with friends or loved ones regularly',
      ];
    }

    return WeeklyReport(
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      averageScore: avgScore,
      highestScore: highestScore,
      lowestScore: lowestScore,
      totalEntries: weekMoods.length,
      summary: summary,
      recommendations: recommendations,
      generatedAt: DateTime.now(),
    );
  }
}