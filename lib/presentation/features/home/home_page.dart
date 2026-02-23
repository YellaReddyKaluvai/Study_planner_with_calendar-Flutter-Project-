import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../shared/glass_container.dart';
import '../../shared/animated_background.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/tasks/task_page.dart';
import '../../features/tasks/widgets/task_creation_sheet.dart';
import '../../features/gamification/game_center_page.dart';
import '../../features/chatbot/chatbot_page.dart';
import '../../features/focus/focus_timer_page.dart';
import '../../features/analytics/analytics_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/profile/presentation/profile_page.dart';

// Move the Dashboard content here
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Consumer2<TaskProvider, AnalyticsProvider>(
      builder: (context, taskProvider, analyticsProvider, _) {
        final completedTasks =
            taskProvider.tasks.where((t) => t.isCompleted).length;
        final totalTasks = taskProvider.tasks.length;

        // Format today's focus minutes from analytics
        final focusMins = analyticsProvider.totalStudyTime;
        final focusLabel = focusMins >= 60
            ? '${focusMins ~/ 60}h ${focusMins % 60}m'
            : '${focusMins}m';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Welcome back",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.waving_hand,
                              color: Color(0xFFFFC043), size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Ready to focus?",
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(2),
                        borderRadius: BorderRadius.circular(20),
                        gradient: AppTheme.primaryGradient,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.timer, color: AppTheme.primary),
                            tooltip: 'Focus Timer',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FocusTimerPage(),
                                ),
                              ).then((_) {
                                // Refresh analytics when returning from focus timer
                                analyticsProvider.refreshData();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassContainer(
                        padding: const EdgeInsets.all(2),
                        borderRadius: BorderRadius.circular(20),
                        gradient: AppTheme.primaryGradient,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.auto_awesome,
                                color: AppTheme.primary),
                            tooltip: 'AI Chatbot',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChatbotPage()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade(duration: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),

              Text("Quick Stats",
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 16),

              // Row 1: Tasks
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: "Tasks Done",
                      value: "$completedTasks",
                      icon: Icons.check_circle_outline,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: "Total Tasks",
                      value: "$totalTasks",
                      icon: Icons.assignment,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              // Row 2: Focus time stat
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: "Focus Time",
                      value: focusMins == 0 ? '—' : focusLabel,
                      icon: Icons.timer_outlined,
                      color: const Color(0xFF00F0FF),
                      subtitle: 'total logged',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: "Avg Session",
                      value: analyticsProvider.averageSessionTime == 0
                          ? '—'
                          : '${analyticsProvider.averageSessionTime.toInt()}m',
                      icon: Icons.trending_up,
                      color: const Color(0xFFFFA500),
                      subtitle: 'per session',
                    ),
                  ),
                ],
              ).animate().fade(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 32),

              // Analytics chart + subject
              const AnalyticsDashboard()
                  .animate()
                  .fade(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white10 : Colors.black12, size: 12),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.outfit(fontSize: 12, color: subtextColor)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const DashboardPage(),
      const CalendarPage(),
      const TaskPage(), // Placeholder for +
      const GameCenterPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Global Background
          const AnimatedBackground(),
          pages[navProvider.currentIndex],
        ],
      ),
      bottomNavigationBar: GlassContainer(
        margin: const EdgeInsets.all(24),
        height: 70,
        borderRadius: BorderRadius.circular(50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarIcon(
                icon: Icons.home_filled, index: 0, provider: navProvider),
            _NavBarIcon(
                icon: Icons.calendar_month, index: 1, provider: navProvider),
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TaskCreationSheet(),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              mini: true,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            _NavBarIcon(icon: Icons.games, index: 3, provider: navProvider),
            _NavBarIcon(icon: Icons.person, index: 4, provider: navProvider),
          ],
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final NavigationProvider provider;

  const _NavBarIcon(
      {required this.icon, required this.index, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.white54 : Colors.black45;
    
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : inactiveColor,
        size: 28,
      ),
      onPressed: () => provider.setIndex(index),
    );
  }
}
