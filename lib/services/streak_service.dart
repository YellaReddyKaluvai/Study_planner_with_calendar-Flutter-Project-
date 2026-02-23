import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Service to track and manage study streaks
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _lastStudyDateKey = 'last_study_date';
  static const String _streakFrozenKey = 'streak_frozen';

  late SharedPreferences _prefs;
  final AnalyticsService _analyticsService = AnalyticsService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _analyticsService.init();
    _updateStreakIfNeeded();
  }

  /// Check if user studied today and update streak
  Future<void> _updateStreakIfNeeded() async {
    final currentStreak = _prefs.getInt(_currentStreakKey) ?? 0;
    final lastStudyDate = _prefs.getString(_lastStudyDateKey);
    final today = _getTodayString();

    if (lastStudyDate == null || lastStudyDate != today) {
      // Check if user studied today
      final sessionsToday = await _analyticsService.getSessionsCountToday();
      if (sessionsToday > 0) {
        if (lastStudyDate != null && _isConsecutiveDay(lastStudyDate, today)) {
          // Extend streak
          await _prefs.setInt(_currentStreakKey, currentStreak + 1);
        } else if (lastStudyDate == null) {
          // First day of streak
          await _prefs.setInt(_currentStreakKey, 1);
        } else {
          // Streak broken, reset to 1
          await _prefs.setInt(_currentStreakKey, 1);
        }

        // Update last study date
        await _prefs.setString(_lastStudyDateKey, today);

        // Update longest streak if needed
        final newStreak = _prefs.getInt(_currentStreakKey) ?? 1;
        final longestStreak = _prefs.getInt(_longestStreakKey) ?? 0;
        if (newStreak > longestStreak) {
          await _prefs.setInt(_longestStreakKey, newStreak);
        }
      }
    }
  }

  /// Get current study streak
  int getCurrentStreak() {
    return _prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Get longest study streak ever achieved
  int getLongestStreak() {
    return _prefs.getInt(_longestStreakKey) ?? 0;
  }

  /// Check if streak is frozen (earned a freeze)
  bool isStreakFrozen() {
    return _prefs.getBool(_streakFrozenKey) ?? false;
  }

  /// Freeze the current streak for one missed day
  Future<void> freezeStreak() async {
    await _prefs.setBool(_streakFrozenKey, true);
  }

  /// Use a freeze (one missed day won't break streak)
  Future<void> useFreeze() async {
    await _prefs.setBool(_streakFrozenKey, false);
  }

  /// Get days until streak resets if not studied
  int getDaysUntilStreakReset() {
    final lastStudyDate = _prefs.getString(_lastStudyDateKey);
    if (lastStudyDate == null) return 1;

    final lastDate = DateTime.parse('${lastStudyDate}T00:00:00');
    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastDate).inDays;

    return (1 - daysSinceLastStudy).clamp(0, 1);
  }

  /// Reset streak (for admin/testing purposes)
  Future<void> resetStreak() async {
    await _prefs.remove(_currentStreakKey);
    await _prefs.remove(_lastStudyDateKey);
    await _prefs.setBool(_streakFrozenKey, false);
  }

  /// Get streak milestone badges
  List<StreakBadge> getStreakBadges() {
    final currentStreak = getCurrentStreak();
    final badges = <StreakBadge>[];

    if (currentStreak >= 7) {
      badges.add(StreakBadge(
        name: 'Week Warrior',
        description: 'Studied for 7 days straight',
        emoji: '🔥',
        requirement: 7,
      ));
    }
    if (currentStreak >= 30) {
      badges.add(StreakBadge(
        name: 'Month Master',
        description: 'Studied for 30 days straight',
        emoji: '⭐',
        requirement: 30,
      ));
    }
    if (currentStreak >= 100) {
      badges.add(StreakBadge(
        name: 'Century Champion',
        description: 'Studied for 100 days straight',
        emoji: '👑',
        requirement: 100,
      ));
    }
    if (currentStreak >= 365) {
      badges.add(StreakBadge(
        name: 'Golden Scholar',
        description: 'Studied for a full year straight',
        emoji: '✨',
        requirement: 365,
      ));
    }

    return badges;
  }

  /// Get next streak milestone
  StreakMilestone? getNextMilestone() {
    final currentStreak = getCurrentStreak();
    const milestones = [7, 14, 30, 60, 100, 365];

    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return StreakMilestone(
          target: milestone,
          daysRemaining: milestone - currentStreak,
          reward: _getMilestoneReward(milestone),
        );
      }
    }

    return null;
  }

  String _getMilestoneReward(int days) {
    switch (days) {
      case 7:
        return '+10 XP';
      case 14:
        return '+25 XP';
      case 30:
        return '+50 XP + Streak Freeze';
      case 60:
        return '+100 XP';
      case 100:
        return '+250 XP + Gold Badge';
      case 365:
        return '+1000 XP + Platinum Badge';
      default:
        return '+5 XP';
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _isConsecutiveDay(String lastDate, String today) {
    final last = DateTime.parse('${lastDate}T00:00:00');
    final next = DateTime.parse('${today}T00:00:00');
    return next.difference(last).inDays == 1;
  }
}

/// Represents a streak badge earned
class StreakBadge {
  final String name;
  final String description;
  final String emoji;
  final int requirement;

  StreakBadge({
    required this.name,
    required this.description,
    required this.emoji,
    required this.requirement,
  });
}

/// Represents the next streak milestone
class StreakMilestone {
  final int target;
  final int daysRemaining;
  final String reward;

  StreakMilestone({
    required this.target,
    required this.daysRemaining,
    required this.reward,
  });

  double get progressPercent => (target - daysRemaining) / target;
}
