import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home_Components/crisis_helplines_sheet.dart';
import 'Home_Components/home_header_section.dart';
import 'Home_Components/mental_health_centers_sheet.dart';
import 'Home_Components/resource_card.dart';
import 'Home_Components/self_care_tips_sheet.dart';
import 'Home_Components/stats_section.dart';
import '../gamification/data/services/gamification_service.dart';
import '../gamification/data/models/user_gamification_profile.dart';
import '../gamification/data/models/streak_model.dart';
import '../gamification/presentation/widgets/gamification_stats_widget.dart';
import '../gamification/presentation/widgets/challenges_widget.dart';
import '../gamification/presentation/pages/achievements_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GamificationService _gamificationService = GamificationService();

  @override
  void initState() {
    super.initState();
    _trackSectionVisit();
  }

  void _trackSectionVisit() {
    _gamificationService.trackSectionVisited('home');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _showCrisisHelplines(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CrisisHelplinesSheet(primaryColor: primaryColor),
    );
  }

  void _showSelfCareTips(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SelfCareTipsSheet(primaryColor: primaryColor),
    );
  }

  void _showMentalHealthCenters(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MentalHealthCentersSheet(primaryColor: primaryColor),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            HomeHeaderSection(
              firestore: _firestore,
              auth: _auth,
              getGreeting: _getGreeting,
            ),

            // Stats Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Journey',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatsSection(
                    auth: _auth,
                    firestore: _firestore,
                  ),
                  const SizedBox(height: 24),

                  // Gamification Stats
                  StreamBuilder<UserGamificationProfile>(
                    stream: _gamificationService.pointsService.getUserProfileStream(user?.uid ?? ''),
                    builder: (context, profileSnapshot) {
                      if (!profileSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final profile = profileSnapshot.data!;

                      return FutureBuilder<Map<StreakType, int>>(
                        future: _getStreaks(user?.uid ?? ''),
                        builder: (context, streakSnapshot) {
                          if (!streakSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          return GamificationStatsWidget(
                            profile: profile,
                            streaks: streakSnapshot.data!,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Wellness Challenges
                  const ChallengesWidget(),
                  const SizedBox(height: 32),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionCard(
                    icon: Icons.chat,
                    title: 'Start a Conversation',
                    subtitle: 'Talk to MindHaven about how you\'re feeling',
                    color: primaryColor,
                    onTap: () {
                      Navigator.pop(context); // Go back to chat
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    icon: Icons.book,
                    title: 'Write in Journal',
                    subtitle: 'Capture your thoughts and reflections',
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to journal
                      Navigator.of(context).pushNamed('/journal');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    icon: Icons.analytics,
                    title: 'View Mood Insights',
                    subtitle: 'Track your emotional patterns',
                    color: Colors.teal,
                    onTap: () {
                      // Navigate to mood dashboard
                      Navigator.of(context).pushNamed('/mood-insights');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    icon: Icons.emoji_events,
                    title: 'View Achievements',
                    subtitle: 'See your unlocked badges and progress',
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AchievementsPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Mental Health Resources
                  const Text(
                    'Support Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ResourceCard(
                    icon: Icons.phone,
                    title: 'Crisis Helplines',
                    subtitle: 'Immediate support when you need it',
                    onTap: () => _showCrisisHelplines(context, primaryColor),
                  ),
                  const SizedBox(height: 12),
                  ResourceCard(
                    icon: Icons.self_improvement,
                    title: 'Self-Care Tips',
                    subtitle: 'Daily practices for mental wellness',
                    onTap: () => _showSelfCareTips(context, primaryColor),
                  ),
                  const SizedBox(height: 12),
                  ResourceCard(
                    icon: Icons.local_hospital,
                    title: 'Mental Health Centers',
                    subtitle: 'Professional help in Zambia',
                    onTap: () => _showMentalHealthCenters(context, primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<StreakType, int>> _getStreaks(String userId) async {
    final streaks = await _gamificationService.streakService.getAllStreaks(userId);
    return streaks.map((key, value) => MapEntry(key, value.currentStreak));
  }
}