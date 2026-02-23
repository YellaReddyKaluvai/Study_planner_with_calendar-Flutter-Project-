import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/animated_background.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Logo / Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF00F0FF), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 64,
                        color: Color(0xFF00F0FF),
                      ),
                    )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.elasticOut)
                        .fade(duration: 500.ms),
                  ),

                  const SizedBox(height: 48),

                  Text(
                    "Study Smarter,\nNot Harder.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  )
                      .animate()
                      .slideY(
                          begin: 0.3, end: 0, delay: 200.ms, duration: 600.ms)
                      .fade(delay: 200.ms),

                  const SizedBox(height: 16),

                  Text(
                    "The all-in-one productivity super-app designed for elite students. Focus, plan, and play.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  )
                      .animate()
                      .slideY(
                          begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms)
                      .fade(delay: 400.ms),

                  const Spacer(),

                  // Features Carousel Placeholder or simple icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeatureIcon(Icons.calendar_month, "Plan"),
                      _FeatureIcon(Icons.bolt, "Focus"),
                      _FeatureIcon(Icons.games, "Play"),
                      _FeatureIcon(Icons.auto_awesome, "AI"),
                    ],
                  ).animate().fade(delay: 600.ms),

                  const Spacer(),

                  // Get Started Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => const LoginPage(),
                          transitionsBuilder: (c, a1, a2, child) =>
                              FadeTransition(opacity: a1, child: child),
                          transitionDuration: const Duration(milliseconds: 800),
                        ),
                      );
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00F0FF), Color(0xFF7B61FF)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .slideY(begin: 1, end: 0, delay: 800.ms, duration: 600.ms)
                      .shimmer(delay: 1500.ms, duration: 1500.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
