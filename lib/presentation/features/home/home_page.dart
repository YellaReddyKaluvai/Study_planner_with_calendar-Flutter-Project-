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
import '../../features/profile/profile_page.dart';

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
                  const Text(
                    "Welcome back,",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ready to focus?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(16),
                child: IconButton(
                  icon:
                      const Icon(Icons.auto_awesome, color: Color(0xFF00F0FF)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatbotPage()),
                    );
                  },
                ),
              ),
            ],
          ).animate().fade(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 32),

          GlassContainer(
            height: 200,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Productivity Pulse",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.bolt, color: Theme.of(context).primaryColor),
                  ],
                ),
                const Spacer(),
                const Center(
                  child: Text(
                    "Charts coming soon...",
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
                const Spacer(),
              ],
            ),
          )
              .animate()
              .fade(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
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
