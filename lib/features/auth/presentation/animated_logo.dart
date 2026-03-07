import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedGradientLogo extends StatefulWidget {
  final double size;

  const AnimatedGradientLogo({super.key, this.size = 150});

  @override
  State<AnimatedGradientLogo> createState() => _AnimatedGradientLogoState();
}

class _AnimatedGradientLogoState extends State<AnimatedGradientLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LogoPainter(_controller.value),
          );
        },
      ),
    )
        .animate()
        // Entrance animations
        .scale(duration: 800.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }
}

class _LogoPainter extends CustomPainter {
  final double progress;

  _LogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Glowing background core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.5),
          const Color(0xFF8B5CF6).withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));

    // Core pulsing effect based on progress
    final pulseRadius = radius * 1.5 + (sin(progress * pi * 2) * 10);
    canvas.drawCircle(center, pulseRadius, corePaint);

    // Outer orbiting rings
    final ringPaint1 = Paint()
      ..color = const Color(0xFF14B8A6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final ringPaint2 = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Save canvas to rotate
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * pi * 2);
    canvas.translate(-center.dx, -center.dy);

    final rect1 = Rect.fromCircle(center: center, radius: radius * 0.8);
    canvas.drawArc(rect1, 0, pi * 1.5, false, ringPaint1);

    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-progress * pi * 2);
    canvas.translate(-center.dx, -center.dy);

    final rect2 = Rect.fromCircle(center: center, radius: radius * 1.1);
    canvas.drawArc(rect2, pi / 2, pi * 1.5, false, ringPaint2);

    canvas.restore();

    // Infinity / Glass shape inside
    final pathPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(center.dx - radius * 0.5, center.dy - radius * 0.5);
    path.cubicTo(
      center.dx + radius * 0.5,
      center.dy - radius * 0.5,
      center.dx - radius * 0.5,
      center.dy + radius * 0.5,
      center.dx + radius * 0.5,
      center.dy + radius * 0.5,
    );
    path.cubicTo(
      center.dx + radius,
      center.dy,
      center.dx - radius,
      center.dy,
      center.dx - radius * 0.5,
      center.dy - radius * 0.5,
    );

    canvas.drawPath(path, pathPaint);

    // Core shining dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawCircle(center, 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
