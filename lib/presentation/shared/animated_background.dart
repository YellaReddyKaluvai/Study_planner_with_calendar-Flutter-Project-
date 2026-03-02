import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// Theme-aware animated background.
/// Dark mode: deep space with purple nebula + stars.
/// Light mode: clean sky with soft clouds + subtle particles.
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ─── Base Color ────────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: isDark ? const Color(0xFF0A0E17) : const Color(0xFFF0F4FF),
        ),

        // ─── Moving Gradient ───────────────────────────────────────────────
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: -1.0, end: 1.0),
          duration: const Duration(seconds: 15),
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(value, -1),
                  end: Alignment(-value, 1),
                  colors: isDark
                      ? [
                          const Color(0xFF0A0E17),
                          const Color(0xFF1A1F2E).withOpacity(0.9),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          const Color(0xFFF0F4FF),
                          const Color(0xFFE8EEFF).withOpacity(0.95),
                          const Color(0xFFF8FAFF),
                        ],
                ),
              ),
            );
          },
        ),

        // ─── Nebula / Glow Effect ──────────────────────────────────────────
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 2 * pi),
          duration: const Duration(seconds: 25),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center:
                        Alignment(0.5 + 0.3 * cos(value), 0.3 + 0.2 * sin(value)),
                    radius: 1.5,
                    colors: isDark
                        ? [
                            const Color(0xFF7B61FF).withOpacity(0.15),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFF6366F1).withOpacity(0.08),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            );
          },
        ),

        // ─── Secondary Glow ────────────────────────────────────────────────
        if (!isDark)
          MirrorAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 2 * pi),
            duration: const Duration(seconds: 18),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                          -0.4 + 0.2 * sin(value), 0.6 + 0.15 * cos(value)),
                      radius: 1.2,
                      colors: [
                        const Color(0xFF14B8A6).withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        // ─── Particles ─────────────────────────────────────────────────────
        Positioned.fill(
          child: ParticleSystem(isDark: isDark),
        ),
      ],
    );
  }
}

class ParticleSystem extends StatefulWidget {
  final bool isDark;
  const ParticleSystem({super.key, required this.isDark});

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    for (int i = 0; i < 30; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2 + 0.5,
      speed: _random.nextDouble() * 0.04 + 0.008,
      opacity: _random.nextDouble() * 0.5 + 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var p in _particles) {
          p.y -= p.speed * 0.18;
          if (p.y < 0) {
            p.y = 1.0;
            p.x = _random.nextDouble();
          }
        }
        return CustomPaint(
          painter: ParticlePainter(_particles, isDark: widget.isDark),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  Particle(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final bool isDark;
  ParticlePainter(this.particles, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      // In light mode, use soft indigo dots; in dark mode use white stars
      paint.color = isDark
          ? Colors.white.withOpacity(p.opacity)
          : const Color(0xFF6366F1).withOpacity(p.opacity * 0.4);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
