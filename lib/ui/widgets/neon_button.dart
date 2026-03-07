import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_theme.dart';

class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String animationType; // 'click', 'save', 'add', 'delete'
  final bool showConfetti;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.animationType = 'click',
    this.showConfetti = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _showAnimation = false;
  bool _showConfetti = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() {
      _showAnimation = true;
      _isPressed = true;
    });

    _animController.forward(from: 0);

    if (widget.showConfetti) {
      setState(() => _showConfetti = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showConfetti = false);
      });
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showAnimation = false;
          _isPressed = false;
        });
      }
    });

    widget.onTap();
  }

  String _getAnimationPath() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.animationType) {
      case 'save':
        return 'assets/lottie/save.json';
      case 'add':
        return 'assets/lottie/add.json';
      case 'delete':
        return 'assets/lottie/delete.json';
      case 'click':
      default:
        return isDark
            ? 'assets/lottie/button_click.json'
            : 'assets/lottie/button_click_dark.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _handlePress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.neonCyan, AppTheme.neonPink],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonCyan.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, color: Colors.black, size: 20),
                if (widget.icon != null) const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Lottie click animation
        if (_showAnimation)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 1.5,
                child: Lottie.asset(
                  _getAnimationPath(),
                  controller: _animController,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
          ),

        // Confetti animation
        if (_showConfetti)
          Positioned(
            top: -50,
            child: IgnorePointer(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  fit: BoxFit.cover,
                  repeat: false,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
