import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedNeonBackground extends StatefulWidget {
  final Widget child;
  const AnimatedNeonBackground({super.key, required this.child});

  @override
  State<AnimatedNeonBackground> createState() => _AnimatedNeonBackgroundState();
}

class _AnimatedNeonBackgroundState extends State<AnimatedNeonBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 0.8).animate(
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
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.5, -0.7),
              radius: 1.2,
              colors: [
                AppTheme.neonCyan.withOpacity(_pulse.value),
                AppTheme.bgDark,
                AppTheme.bgDark,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.neonPink.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}
