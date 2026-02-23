import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/study_session.dart';

/// Service to track and analyze study sessions for analytics and insights
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _sessionsKey = 'study_sessions';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Record a completed study session
  Future<void> recordSession(StudySession session) async {
    try {
      final sessions = await getAllSessions();
      sessions.add(session);

      final jsonList = sessions.map((s) => s.toJson()).toList();
      await _prefs.setString(_sessionsKey, jsonEncode(jsonList));
    } catch (e) {
      print("Error recording session: $e");
    }
  }

  /// Get all recorded study sessions
  Future<List<StudySession>> getAllSessions() async {
    try {
      final jsonString = _prefs.getString(_sessionsKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => StudySession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting sessions: $e");
      return [];
    }
  }

  /// Get sessions from last N days
  Future<List<StudySession>> getSessionsFromLastDays(int days) async {
    final sessions = await getAllSessions();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return sessions
        .where((s) => s.endTime != null && s.endTime!.isAfter(cutoffDate))
        .toList();
  }

  /// Get total study time in minutes for a date
  Future<int> getTotalStudyTimeForDate(DateTime date) async {
    final sessions = await getAllSessions();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return sessions
        .where((s) => s.startTime.toString().startsWith(dateStr))
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Get daily study time for last 7 days
  Future<Map<String, int>> getWeeklyStudyTime() async {
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final total = await getTotalStudyTimeForDate(date);
      result['${date.month}/${date.day}'] = total;
    }
    return result;
  }

  /// Get daily study time for last 30 days
  Future<Map<String, int>> getMonthlyStudyTime() async {
    final result = <String, int>{};
    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final total = await getTotalStudyTimeForDate(date);
      result['${date.month}/${date.day}'] = total;
    }
    return result;
  }

  /// Get total study time across all sessions
  Future<int> getTotalStudyTime() async {
    final sessions = await getAllSessions();
    return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Get average session duration in minutes
  Future<double> getAverageSessionDuration() async {
    final sessions = await getAllSessions();
    if (sessions.isEmpty) return 0;
    final total = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    return total / sessions.length;
  }

  /// Get most productive subject
  Future<String?> getMostProductiveSubject() async {
    final sessions = await getAllSessions();
    if (sessions.isEmpty) return null;

    final subjectMap = <String, int>{};
    for (final session in sessions) {
      subjectMap[session.subject] =
          (subjectMap[session.subject] ?? 0) + session.durationMinutes;
    }

    return subjectMap.isEmpty
        ? null
        : subjectMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get study time by subject
  Future<Map<String, int>> getStudyTimeBySubject() async {
    final sessions = await getAllSessions();
    final result = <String, int>{};

    for (final session in sessions) {
      result[session.subject] =
          (result[session.subject] ?? 0) + session.durationMinutes;
    }

    return result;
  }

  /// Get number of sessions today
  Future<int> getSessionsCountToday() async {
    final sessions = await getAllSessions();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return sessions
        .where((s) => s.startTime.toString().startsWith(todayStr))
        .length;
  }

  /// Get productivity score (0-100) based on sessions this week
  Future<int> getWeeklyProductivityScore() async {
    final sessions = await getSessionsFromLastDays(7);
    final targetMinutes = 300; // 5 hours per week target

    if (sessions.isEmpty) return 0;

    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final score = ((totalMinutes / targetMinutes) * 100).toInt().clamp(0, 100);

    return score;
  }

  /// Clear all sessions (use with caution!)
  Future<void> clearAllSessions() async {
    await _prefs.remove(_sessionsKey);
  }
}
