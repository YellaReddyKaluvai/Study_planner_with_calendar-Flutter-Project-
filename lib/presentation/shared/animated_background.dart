import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// Theme-aware animated background with enhanced depth and motion.
/// Dark mode: deep space with purple nebula + stars + floating orbs.
/// Light mode: clean sky with soft clouds + subtle particles + gradient mesh.
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0A0E17),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFEFF2FA),
                      const Color(0xFFE0E7F8),
                    ],
            ),
          ),
        ),

        // ─── Moving Gradient Mesh ──────────────────────────────────────────
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: -1.0, end: 1.0),
          duration: const Duration(seconds: 20),
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(value * 0.8, -1),
                  end: Alignment(-value * 0.8, 1),
                  colors: isDark
                      ? [
                          const Color(0xFF0A0E17),
                          const Color(0xFF1A1F2E).withOpacity(0.95),
                          const Color(0xFF0F172A),
                          const Color(0xFF1E293B).withOpacity(0.8),
                        ]
                      : [
                          const Color(0xFFF0F3FD),
                          const Color(0xFFE8EDFA).withOpacity(0.98),
                          const Color(0xFFF2EEFA).withOpacity(0.95),
                          const Color(0xFFE6F0FA),
                        ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            );
          },
        ),

        // ─── Primary Nebula / Glow Effect ──────────────────────────────────
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 2 * pi),
          duration: const Duration(seconds: 30),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.5 + 0.4 * cos(value),
                      0.2 + 0.3 * sin(value),
                    ),
                    radius: 1.8,
                    colors: isDark
                        ? [
                            const Color(0xFF7B61FF).withOpacity(0.25),
                            const Color(0xFF6366F1).withOpacity(0.15),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFF6366F1).withOpacity(0.20),
                            const Color(0xFF818CF8).withOpacity(0.12),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            );
          },
        ),

        // ─── Secondary Glow (Teal accent) ──────────────────────────────────
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 2 * pi),
          duration: const Duration(seconds: 25),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.5 + 0.3 * sin(value * 1.3),
                      0.7 + 0.2 * cos(value * 1.3),
                    ),
                    radius: 1.5,
                    colors: isDark
                        ? [
                            const Color(0xFF14B8A6).withOpacity(0.2),
                            const Color(0xFF2DD4BF).withOpacity(0.1),
                            Colors.transparent,
                          ]
                        : [
                            const Color(0xFF14B8A6).withOpacity(0.18),
                            const Color(0xFF5EEAD4).withOpacity(0.10),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            );
          },
        ),

        // ─── Tertiary Glow (Pink/Orange) ───────────────────────────────────
        if (isDark)
          MirrorAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 2 * pi),
            duration: const Duration(seconds: 35),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.8 + 0.2 * cos(value * 0.7),
                        -0.3 + 0.25 * sin(value * 0.7),
                      ),
                      radius: 1.2,
                      colors: [
                        const Color(0xFFEC4899).withOpacity(0.15),
                        const Color(0xFFF97316).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        // ─── Floating Orbs ─────────────────────────────────────────────────
        Positioned.fill(
          child: FloatingOrbs(isDark: isDark),
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

// ─── FLOATING ORBS WIDGET ──────────────────────────────────────────────────
class FloatingOrbs extends StatefulWidget {
  final bool isDark;
  const FloatingOrbs({super.key, required this.isDark});

  @override
  State<FloatingOrbs> createState() => _FloatingOrbsState();
}

class _FloatingOrbsState extends State<FloatingOrbs>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  final List<Orb> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 15 + _random.nextInt(10)),
      )..repeat();
    });

    // Create floating orbs
    _orbs.addAll([
      Orb(
        color: const Color(0xFF6366F1),
        size: 150,
        initialX: 0.1,
        initialY: 0.2,
        opacity: 0.15,
      ),
      Orb(
        color: const Color(0xFF14B8A6),
        size: 120,
        initialX: 0.8,
        initialY: 0.6,
        opacity: 0.12,
      ),
      Orb(
        color: const Color(0xFFEC4899),
        size: 100,
        initialX: 0.3,
        initialY: 0.8,
        opacity: 0.1,
      ),
      Orb(
        color: const Color(0xFFF97316),
        size: 80,
        initialX: 0.7,
        initialY: 0.3,
        opacity: 0.08,
      ),
      Orb(
        color: const Color(0xFFA855F7),
        size: 90,
        initialX: 0.5,
        initialY: 0.5,
        opacity: 0.1,
      ),
    ]);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDark) {
      // Light mode: subtle floating orbs with reduced opacity
      return Stack(
        children: List.generate(_orbs.length, (index) {
          final orb = _orbs[index];
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              final value = _controllers[index].value * 2 * pi;
              final offsetX = orb.initialX + 0.15 * cos(value);
              final offsetY = orb.initialY + 0.1 * sin(value);

              return Positioned(
                left:
                    MediaQuery.of(context).size.width * offsetX - orb.size / 2,
                top:
                    MediaQuery.of(context).size.height * offsetY - orb.size / 2,
                child: Container(
                  width: orb.size,
                  height: orb.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        orb.color.withOpacity(orb.opacity * 0.4),
                        orb.color.withOpacity(orb.opacity * 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      );
    }

    return Stack(
      children: List.generate(_orbs.length, (index) {
        final orb = _orbs[index];
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            final value = _controllers[index].value * 2 * pi;
            final offsetX = orb.initialX + 0.15 * cos(value);
            final offsetY = orb.initialY + 0.1 * sin(value);

            return Positioned(
              left: MediaQuery.of(context).size.width * offsetX - orb.size / 2,
              top: MediaQuery.of(context).size.height * offsetY - orb.size / 2,
              child: Container(
                width: orb.size,
                height: orb.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      orb.color.withOpacity(orb.opacity),
                      orb.color.withOpacity(orb.opacity * 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class Orb {
  final Color color;
  final double size;
  final double initialX;
  final double initialY;
  final double opacity;

  Orb({
    required this.color,
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.opacity,
  });
}

// ─── PARTICLE DATA CLASS ───────────────────────────────────────────────────

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
      // Enhanced particles with glow effect
      paint.color = isDark
          ? Colors.white.withOpacity(p.opacity * 0.8)
          : const Color(0xFF6366F1).withOpacity(p.opacity * 0.5);

      // Add subtle glow in dark mode
      if (isDark && p.size > 1.5) {
        paint.color = Colors.white.withOpacity(p.opacity * 0.3);
        canvas.drawCircle(
          Offset(p.x * size.width, p.y * size.height),
          p.size * 2,
          paint,
        );
      }

      // Main particle
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
