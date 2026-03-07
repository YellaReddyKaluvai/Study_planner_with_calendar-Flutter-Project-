import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onComplete;

  const SuccessDialog({
    super.key,
    required this.message,
    this.onComplete,
  });

  static Future<void> show({
    required BuildContext context,
    required String message,
    VoidCallback? onComplete,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => SuccessDialog(
        message: message,
        onComplete: onComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-dismiss after animation completes
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        onComplete?.call();
      }
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie Animation
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset(
                'assets/lottie/success.json',
                repeat: false,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            // Success Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Checkmark icon
            Icon(
              Icons.check_circle,
              color: Colors.green[400],
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
