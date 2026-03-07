import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// An animated container with flowing gradient background
class AnimatedGradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 5),
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return MirrorAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * pi),
      duration: duration,
      builder: (context, value, child) {
        return Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(cos(value), sin(value)),
              end: Alignment(-cos(value), -sin(value)),
              colors: colors,
            ),
            borderRadius: borderRadius,
            border: border,
            boxShadow: boxShadow,
          ),
          child: this.child,
        );
      },
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MirrorAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                max(0.0, value - 0.3),
                max(0.0, value),
                min(1.0, value + 0.3),
              ],
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.black.withOpacity(0.03),
                      Colors.black.withOpacity(0.08),
                      Colors.black.withOpacity(0.03),
                    ],
            ),
          ),
        );
      },
    );
  }
}

/// Pulse glow effect
class PulseGlow extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;

  const PulseGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.minOpacity = 0.3,
    this.maxOpacity = 0.8,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return MirrorAnimationBuilder<double>(
      tween: Tween(begin: minOpacity, end: maxOpacity),
      duration: duration,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(value),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: this.child,
        );
      },
    );
  }
}
