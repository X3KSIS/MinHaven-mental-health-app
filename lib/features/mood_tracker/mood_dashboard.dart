import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_app/features/mood_tracker/utils/constants.dart';
import 'data/model/mood_entry.dart';
import 'data/model/weekly_report.dart';
import 'data/services/ai_insight_service.dart';
import 'data/services/mood_service.dart';
import 'mood_components/ai_insights_widget.dart';
import 'mood_components/empty_state_widget.dart';
import 'mood_components/mood_chart_widget.dart';
import 'mood_components/mood_dialog.dart';
import 'mood_components/mood_stats_cards.dart';
import 'mood_components/recent_moods_list.dart';
import 'mood_components/weekly_report_card.dart';

class MoodDashboard extends StatefulWidget {
  const MoodDashboard({super.key});

  @override
  State<MoodDashboard> createState() => _MoodDashboardState();
}

class _MoodDashboardState extends State<MoodDashboard> {
  final MoodService _moodService = MoodService();
  final AIInsightService _aiService = AIInsightService();

  List<MoodEntryData> _moods = [];
  String _insight = 'Log your mood to see personalized insights!';
  bool _isLoadingMoods = true;
  bool _isGeneratingInsights = false;
  bool _isGeneratingReport = false;
  String? _cachedInsight;
  DateTime? _insightGeneratedAt;
  WeeklyReport? _latestWeeklyReport;

  @override
  void initState() {
    super.initState();
    _loadMoods();
    _loadLatestWeeklyReport();
  }

  void _loadMoods() {
    _moodService.getMoodsStream(MoodConstants.moodDisplayLimit).listen(
          (moods) {
        if (!mounted) return;

        setState(() {
          _moods = moods;
          _isLoadingMoods = false;
        });

        if (_moods.isNotEmpty) {
          _generateInsights();
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoadingMoods = false;
          _insight = 'Unable to load mood data. Please check your connection.';
        });
      },
    );
  }

  Future<void> _generateInsights() async {
    if (_moods.isEmpty) return;

    if (_cachedInsight != null && _insightGeneratedAt != null) {
      final hoursSinceGenerated = DateTime.now().difference(_insightGeneratedAt!).inHours;
      if (hoursSinceGenerated < 6) {
        setState(() => _insight = _cachedInsight!);
        return;
      }
    }

    setState(() => _isGeneratingInsights = true);

    final recentMoods = _moods.take(MoodConstants.insightsDaysLimit).toList();
    final insight = await _aiService.generateDailyInsights(recentMoods);

    if (!mounted) return;

    setState(() {
      _insight = insight;
      _cachedInsight = insight;
      _insightGeneratedAt = DateTime.now();
      _isGeneratingInsights = false;
    });
  }

  Future<void> _loadLatestWeeklyReport() async {
    final report = await _moodService.getLatestWeeklyReport();
    if (!mounted) return;
    setState(() => _latestWeeklyReport = report);
  }

  Future<void> _generateWeeklyReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      final now = DateTime.now();
      final weekStart = now.subtract(const Duration(days: 7));
      final weekMoods = await _moodService.getMoodsForWeek(weekStart, now);

      if (weekMoods.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough mood data for a weekly report. Log more moods!'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isGeneratingReport = false);
        return;
      }

      final report = await _aiService.generateWeeklyReport(weekMoods, weekStart, now);
      await _moodService.saveWeeklyReport(report);

      if (!mounted) return;

      setState(() {
        _latestWeeklyReport = report;
        _isGeneratingReport = false;
      });

      _showWeeklyReportDialog(report);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isGeneratingReport = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate weekly report. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWeeklyReportDialog(WeeklyReport report) {
    final dateRange = '${DateFormat('MMM dd').format(report.weekStartDate)} - ${DateFormat('MMM dd, yyyy').format(report.weekEndDate)}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assessment,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Report',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dateRange,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildReportStats(report),
                const SizedBox(height: 20),
                _buildReportSummary(report),
                const SizedBox(height: 20),
                _buildRecommendations(report),
                const SizedBox(height: 16),
                _buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportStats(WeeklyReport report) {
    return Row(
      children: [
        Expanded(
          child: _buildReportStatCard('Average', report.averageScore.toStringAsFixed(1), Icons.show_chart, Colors.blue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildReportStatCard('Highest', '${report.highestScore}', Icons.arrow_upward, Colors.green),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildReportStatCard('Lowest', '${report.lowestScore}', Icons.arrow_downward, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildReportStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummary(WeeklyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Text(
            report.summary,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(WeeklyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...report.recommendations.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Got it!'),
      ),
    );
  }

  Future<void> _logMood(int score, String? note) async {
    final canLog = await _moodService.canLogMood();
    if (!canLog) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logging Limit Reached'),
          content: Text(
            'You can log moods up to ${MoodConstants.maxMoodsPerDay} times per day, with at least ${MoodConstants.minHoursBetweenMoods} hours between logs.\n\nTake some time for yourself and check back later!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await _moodService.logMood(score, note ?? '');
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood logged successfully! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to log mood. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMoodDialog() {
    showDialog(
      context: context,
      builder: (context) => MoodDialog(onLogMood: _logMood),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Insights'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          if (_moods.isNotEmpty)
            IconButton(
              icon: _isGeneratingReport
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.summarize),
              onPressed: _isGeneratingReport ? null : _generateWeeklyReport,
              tooltip: 'Generate Weekly Report',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _generateInsights(),
            tooltip: 'Refresh Insights',
          ),
        ],
      ),
      body: _isLoadingMoods
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            const Text('Loading your mood data...'),
          ],
        ),
      )
          : _moods.isEmpty
          ? EmptyStateWidget(
        primaryColor: primaryColor,
        onLogMood: _showMoodDialog,
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoodStatsCards(moods: _moods, primaryColor: primaryColor),
            const SizedBox(height: 16),
            if (_latestWeeklyReport != null)
              WeeklyReportCard(
                report: _latestWeeklyReport!,
                primaryColor: primaryColor,
                onTap: () => _showWeeklyReportDialog(_latestWeeklyReport!),
              ),
            if (_latestWeeklyReport != null) const SizedBox(height: 16),
            MoodChartWidget(moods: _moods, primaryColor: primaryColor),
            const SizedBox(height: 16),
            AIInsightsWidget(
              insight: _insight,
              isLoading: _isGeneratingInsights,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 16),
            RecentMoodsList(moods: _moods, primaryColor: primaryColor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMoodDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Log Mood'),
      ),
    );
  }
}