import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Enhanced animated background with Lottie particle effects
class EnhancedAnimatedBackground extends StatelessWidget {
  final Widget child;
  final bool showParticles;
  final bool showFloatingShapes;

  const EnhancedAnimatedBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.showFloatingShapes = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base background
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: isDark ? const Color(0xFF0A0E17) : const Color(0xFFF0F4FF),
        ),

        // Particles background (subtle animation)
        if (showParticles)
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.15 : 0.08,
              child: Lottie.asset(
                'assets/lottie/particles_bg.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),

        // Floating shapes (more prominent animation)
        if (showFloatingShapes)
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.1 : 0.05,
              child: Lottie.asset(
                'assets/lottie/floating_shapes.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),

        // Child content
        child,
      ],
    );
  }
}
