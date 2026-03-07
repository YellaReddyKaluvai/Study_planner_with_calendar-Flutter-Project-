import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
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
import '../../../core/theme/app_strings.dart';
import '../../../features/profile/presentation/profile_page.dart';
import '../../../ui/widgets/pulse_animation.dart';

// Move the Dashboard content here
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final s = AppStrings.of(context);
    if (hour < 12) return s.goodMorning;
    if (hour < 17) return s.goodAfternoon;
    return s.goodEvening;
  }

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
                            _greeting(context),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.waving_hand,
                              color: Color(0xFFFFC043), size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            textColor,
                            textColor.withOpacity(0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          AppStrings.of(context).todaysTasks,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.timer,
                        tooltip: 'Focus Timer',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FocusTimerPage(),
                            ),
                          ).then((_) {
                            analyticsProvider.refreshData();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.auto_awesome,
                        tooltip: 'AI Chatbot',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatbotPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ).animate().fade(duration: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),

              Text(AppStrings.of(context).quickStats,
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 16),

              // Row 1: Tasks
              Row(
                children: [
                  Expanded(
                    child: AnimatedStatCard(
                      title: AppStrings.of(context).tasksDone,
                      value: "$completedTasks",
                      icon: Icons.check_circle_outline,
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedStatCard(
                      title: AppStrings.of(context).totalTasks,
                      value: "$totalTasks",
                      icon: Icons.assignment,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fade(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              // Row 2: Focus time stat
              Row(
                children: [
                  Expanded(
                    child: AnimatedStatCard(
                      title: AppStrings.of(context).focusTime,
                      value: focusMins == 0 ? '—' : focusLabel,
                      icon: Icons.timer_outlined,
                      color: const Color(0xFF00F0FF),
                      subtitle: AppStrings.of(context).totalLogged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedStatCard(
                      title: AppStrings.of(context).avgSession,
                      value: analyticsProvider.averageSessionTime == 0
                          ? '—'
                          : '${analyticsProvider.averageSessionTime.toInt()}m',
                      icon: Icons.trending_up,
                      color: const Color(0xFFFFA500),
                      subtitle: AppStrings.of(context).perSession,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fade(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

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

// ignore: unused_element
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
    // ignore: unused_element_parameter
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
              Icon(Icons.arrow_forward_ios,
                  color: isDark ? Colors.white10 : Colors.black12, size: 12),
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
            _AnimatedFAB(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TaskCreationSheet(),
                );
              },
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(isSelected ? 12 : 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: InkWell(
        onTap: () => provider.setIndex(index),
        borderRadius: BorderRadius.circular(16),
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : inactiveColor,
          size: isSelected ? 28 : 24,
        ),
      ),
    );
  }
}

/// Animated FloatingActionButton with Lottie animation and ripple effect
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedFAB({required this.onPressed});

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_controller);

    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() => _showAnimation = true);
    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showAnimation = false);
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Pulse effect
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (_controller.value * 0.5),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.3 * (1 - _controller.value)),
                ),
              ),
            );
          },
        ),
        // Main FAB
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 3.14159,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withBlue(255),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _handlePress,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    mini: true,
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            );
          },
        ),
        if (_showAnimation)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 2.0,
                child: Lottie.asset(
                  'assets/lottie/add.json',
                  controller: _controller,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Enhanced Action Button Widget with press animations
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.gradient,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
