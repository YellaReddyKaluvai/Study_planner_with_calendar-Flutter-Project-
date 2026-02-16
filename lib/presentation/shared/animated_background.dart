import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Space Base
        Container(
          color: const Color(0xFF0A0E17),
        ),

        // Moving Gradient 1
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: -1.0, end: 1.0),
          duration: const Duration(seconds: 15),
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(value, -1),
                  end: Alignment(-value, 1),
                  colors: [
                    const Color(0xFF0A0E17),
                    const Color(0xFF1A1F2E).withOpacity(0.8),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            );
          },
        ),

        // Nebula / Plasma Effect
        MirrorAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 2 * 3.14),
          duration: const Duration(seconds: 25),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                        0.5 + 0.3 * cos(value), 0.3 + 0.2 * sin(value)),
                    radius: 1.5,
                    colors: [
                      const Color(0xFF7B61FF)
                          .withOpacity(0.15), // Academic Purple
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Floating Particles (Stars/Dust)
        const Positioned.fill(
          child: ParticleSystem(),
        ),
      ],
    );
  }
}

class ParticleSystem extends StatefulWidget {
  const ParticleSystem({super.key});

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

    // Initialize particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2 + 1,
      speed: _random.nextDouble() * 0.05 + 0.01,
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
        for (var particle in _particles) {
          particle.y -= particle.speed * 0.2; // Move up (Increased speed)
          if (particle.y < 0) {
            particle.y = 1.0;
            particle.x = _random.nextDouble();
          }
        }
        return CustomPaint(
          painter: ParticlePainter(_particles),
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

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
