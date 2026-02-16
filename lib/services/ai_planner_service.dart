import 'dart:math';
import '../models/study_task.dart';

class AiPlannerService {
  /// Simple heuristic based AI:
  /// - Groups tasks by subject and difficulty
  /// - Spreads hard tasks earlier
  /// - Avoids too many minutes in a single day
  List<StudyTask> generatePlan({
    required List<StudyTask> tasks,
    required DateTime startDate,
    int dailyLimitMinutes = 180,
  }) {
    if (tasks.isEmpty) return [];

    tasks.sort((a, b) {
      if (a.difficulty != b.difficulty) {
        return b.difficulty.index.compareTo(a.difficulty.index); // hard first
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    final List<StudyTask> planned = [];
    final Map<DateTime, int> loadPerDay = {};

    DateTime cursor = startDate;

    for (final task in tasks) {
      DateTime assignDay = cursor;

      while (true) {
        final key = DateTime(assignDay.year, assignDay.month, assignDay.day);
        final used = loadPerDay[key] ?? 0;

        if (used + task.estimatedMinutes <= dailyLimitMinutes &&
            assignDay.isBefore(task.dueDate.add(const Duration(days: 1)))) {
          // assign session
          final start = DateTime(key.year, key.month, key.day, 18, 0); // 6pm
          final end = start.add(Duration(minutes: task.estimatedMinutes));
          final updated = task.copyWith(
            scheduledStart: start,
            scheduledEnd: end,
          );
          planned.add(updated);
          loadPerDay[key] = used + task.estimatedMinutes;
          break;
        } else {
          assignDay = assignDay.add(const Duration(days: 1));
        }
      }
    }

    return planned;
  }

  /// Simple pattern detection: calculates streak days and focused subject.
  Map<String, dynamic> detectPatterns(List<StudyTask> tasks) {
    if (tasks.isEmpty) {
      return {
        'streakDays': 0,
        'mostFrequentSubject': null,
        'avgDailyMinutes': 0.0,
      };
    }

    final sessions = tasks
        .where((t) => t.scheduledStart != null && t.isCompleted)
        .toList();

    final Set<DateTime> days = {};
    final Map<String, int> minutesPerSubject = {};
    final Map<DateTime, int> minutesPerDay = {};

    for (final t in sessions) {
      final day =
          DateTime(t.scheduledStart!.year, t.scheduledStart!.month, t.scheduledStart!.day);
      days.add(day);

      minutesPerSubject[t.subject] =
          (minutesPerSubject[t.subject] ?? 0) + t.estimatedMinutes;

      minutesPerDay[day] = (minutesPerDay[day] ?? 0) + t.estimatedMinutes;
    }

    int streak = 0;
    if (days.isNotEmpty) {
      final sorted = days.toList()..sort();
      int currentStreak = 1;
      for (int i = 1; i < sorted.length; i++) {
        if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
          currentStreak++;
        } else {
          streak = max(streak, currentStreak);
          currentStreak = 1;
        }
      }
      streak = max(streak, currentStreak);
    }

    String? mostSubject;
    int maxMinutes = 0;
    minutesPerSubject.forEach((subject, minutes) {
      if (minutes > maxMinutes) {
        maxMinutes = minutes;
        mostSubject = subject;
      }
    });

    final avgDaily = minutesPerDay.isEmpty
        ? 0.0
        : minutesPerDay.values.reduce((a, b) => a + b) /
            minutesPerDay.length.toDouble();

    return {
      'streakDays': streak,
      'mostFrequentSubject': mostSubject,
      'avgDailyMinutes': avgDaily,
    };
  }
}
