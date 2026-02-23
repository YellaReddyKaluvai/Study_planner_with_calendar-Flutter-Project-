import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48), // Space for status bar
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
                          color: Colors.white70,
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
                      color: Colors.white,
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
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.timer, color: Color(0xFF00F0FF)),
                        tooltip: 'Focus Timer',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FocusTimerPage(),
                            ),
                          );
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
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.auto_awesome,
                            color: Color(0xFF00F0FF)),
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
                  color: Colors.white)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Tasks Done",
                  value: "12",
                  icon: Icons.check_circle_outline,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: "Focus Time",
                  value: "4h 20m",
                  icon: Icons.timer,
                  color: AppTheme.primary,
                ),
              ),
            ],
          )
              .animate()
              .fade(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 32),

          // Real Analytics Dashboard
          const AnalyticsDashboard()
              .animate()
              .fade(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 12),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
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
              child: const Icon(Icons.add, color: Colors.black),
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
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.white54,
        size: 28,
      ),
      onPressed: () => provider.setIndex(index),
    );
  }
}
