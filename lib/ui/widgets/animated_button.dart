import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A wrapper widget that adds Lottie animations to buttons
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? animationType; // 'click', 'save', 'add', 'delete', 'loading'
  final bool showConfetti;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.animationType,
    this.showConfetti = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showAnimation = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.onPressed != null) {
      setState(() => _showAnimation = true);
      _controller.forward(from: 0);

      if (widget.showConfetti) {
        setState(() => _showConfetti = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showConfetti = false);
        });
      }

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showAnimation = false);
      });

      widget.onPressed!();
    }
  }

  String? _getAnimationPath() {
    // Check theme for light mode animations with better visibility
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.animationType == null) {
      return isDark
          ? 'assets/lottie/button_click.json'
          : 'assets/lottie/button_click_dark.json';
    }

    switch (widget.animationType) {
      case 'click':
        return isDark
            ? 'assets/lottie/button_click.json'
            : 'assets/lottie/button_click_dark.json';
      case 'save':
        return 'assets/lottie/save.json';
      case 'add':
        return 'assets/lottie/add.json';
      case 'delete':
        return 'assets/lottie/delete.json';
      case 'loading':
        return 'assets/lottie/loading.json';
      default:
        return isDark
            ? 'assets/lottie/button_click.json'
            : 'assets/lottie/button_click_dark.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // The actual button
        GestureDetector(
          onTap: _handlePress,
          child: widget.child,
        ),

        // Lottie animation overlay
        if (_showAnimation)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                _getAnimationPath()!,
                controller: _controller,
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),
          ),

        // Confetti animation
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/confetti.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ),
      ],
    );
  }
}

/// Enhanced NeonButton with Lottie animations
class AnimatedNeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String animationType;
  final bool showConfetti;

  const AnimatedNeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.animationType = 'click',
    this.showConfetti = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onTap,
      animationType: animationType,
      showConfetti: showConfetti,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00F5FF), Color(0xFFFF00FF)],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5FF).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.black, size: 20),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced IconButton with animation
class AnimatedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String animationType;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.animationType = 'click',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      animationType: animationType,
      child: Icon(icon, color: color, size: size),
    );
  }
}
