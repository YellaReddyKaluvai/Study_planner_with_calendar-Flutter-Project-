import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animated loading button with Lottie spinner
class LoadingButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(LoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: widget.textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: widget.isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: Lottie.asset(
                'assets/lottie/loading.json',
                controller: _controller,
                fit: BoxFit.contain,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Animated icon button with ripple effect
class RippleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const RippleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  State<RippleIconButton> createState() => _RippleIconButtonState();
}

class _RippleIconButtonState extends State<RippleIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showRipple = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() => _showRipple = true);
    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showRipple = false);
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(widget.icon),
          onPressed: _handlePress,
          color: widget.color,
          iconSize: widget.size,
        ),
        if (_showRipple)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 2.0,
                child: Lottie.asset(
                  isDark
                      ? 'assets/lottie/button_click.json'
                      : 'assets/lottie/button_click_dark.json',
                  controller: _controller,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
