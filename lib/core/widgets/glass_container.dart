import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double opacity;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Gradient? borderGradient;

  const GlassContainer({
    super.key,
    this.width,
    this.height,
    this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.gradient,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.2),
                width: borderWidth,
              ),
              gradient: gradient ??
                  LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
