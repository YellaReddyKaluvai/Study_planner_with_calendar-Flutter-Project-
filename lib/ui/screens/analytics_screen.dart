import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/planner_provider.dart';
import '../widgets/neon_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlannerProvider>(context);
    final patterns = provider.getPatterns();

    final streak = patterns['streakDays'] as int;
    final subject = patterns['mostFrequentSubject'] as String?;
    final avgDaily = patterns['avgDailyMinutes'] as double;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            NeonCard(
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.orangeAccent, size: 34),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      streak == 0
                          ? 'No streak yet. Start studying today to begin a streak!'
                          : 'You have a $streak-day study streak. Keep it going!',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            NeonCard(
              child: Row(
                children: [
                  const Icon(Icons.book_rounded,
                      color: Colors.cyanAccent, size: 34),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      subject == null
                          ? 'No dominant subject yet. Add more scheduled study sessions.'
                          : 'You focus most on $subject.\nConsider balancing with other subjects.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            NeonCard(
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded,
                      color: Colors.pinkAccent, size: 34),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      avgDaily == 0
                          ? 'No study sessions recorded. Start planning to see your average.'
                          : 'On average, you study ${avgDaily.toStringAsFixed(0)} minutes per active day.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use AI scheduling from the Tasks tab regularly to keep your workload balanced, and track your streak on this page.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
