import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'animated_logo.dart';
import 'auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _fadeOutController;
  bool _showTitle = false;
  bool _showSubtitle = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showTitle = true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showSubtitle = true);
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _fadeOutController.forward().then((_) {
          if (mounted) _navigateToApp();
        });
      }
    });
  }

  void _navigateToApp() {
    final user = ref.read(currentUserProvider);
    final isLoggedIn = user != null && user.isNotEmpty;
    if (mounted) {
      context.go(isLoggedIn ? '/' : '/login');
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _fadeOutController,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _fadeOutController.value,
          child: child,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Animated gradient background
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                final t = _bgController.value;
                return Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        -1.0 + sin(t * 2 * pi) * 0.5,
                        -1.0 + cos(t * 2 * pi) * 0.3,
                      ),
                      end: Alignment(
                        1.0 - sin(t * 2 * pi) * 0.3,
                        1.0 - cos(t * 2 * pi) * 0.5,
                      ),
                      colors: const [
                        Color(0xFF0F0A2E),
                        Color(0xFF1E1B4B),
                        Color(0xFF312E81),
                        Color(0xFF0F172A),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                );
              },
            ),

            // Floating particles
            ...List.generate(20, (i) {
              final random = Random(i * 42);
              final startX = random.nextDouble() * screenSize.width;
              final startY = random.nextDouble() * screenSize.height;
              final size = random.nextDouble() * 3 + 1.5;
              final isIndigo = random.nextBool();

              return Positioned(
                left: startX,
                top: startY,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isIndigo
                        ? const Color(0xFF8B5CF6).withOpacity(0.4)
                        : Colors.white.withOpacity(0.25),
                    boxShadow: [
                      BoxShadow(
                        color: isIndigo
                            ? const Color(0xFF8B5CF6).withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                    .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .fadeIn(
                      delay: Duration(milliseconds: 300 + random.nextInt(1500)),
                      duration:
                          Duration(milliseconds: 1200 + random.nextInt(1500)),
                    )
                    .fadeOut(
                      delay:
                          Duration(milliseconds: 1200 + random.nextInt(1500)),
                    )
                    .moveY(
                      begin: 0,
                      end: -15.0 - random.nextDouble() * 25,
                      duration:
                          Duration(milliseconds: 2500 + random.nextInt(2500)),
                    ),
              );
            }),

            // Center content — Same AnimatedGradientLogo as login page
            const Center(
              child: AnimatedGradientLogo(size: 180),
            ),

            // Bottom title area
            Positioned(
              left: 0,
              right: 0,
              bottom: screenSize.height * 0.1,
              child: Column(
                children: [
                  // App Title with gradient
                  AnimatedOpacity(
                    opacity: _showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    child: AnimatedSlide(
                      offset: _showTitle ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF6366F1),
                            Color(0xFF14B8A6),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Study Planner Ultra',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Subtitle
                  AnimatedOpacity(
                    opacity: _showSubtitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    child: AnimatedSlide(
                      offset:
                          _showSubtitle ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      child: Text(
                        'ELEVATE YOUR PRODUCTIVITY',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Loading indicator
                  AnimatedOpacity(
                    opacity: _showSubtitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
