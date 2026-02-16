import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.neonCyan.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
