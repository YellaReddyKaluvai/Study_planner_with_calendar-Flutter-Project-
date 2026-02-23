import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';
import '../../services/streak_service.dart';

/// Provider to manage analytics data and state
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  final StreakService _streakService = StreakService();

  bool _isLoading = true;
  String? _error;

  // Analytics data
  Map<String, int> _weeklyData = {};
  Map<String, int> _monthlyData = {};
  Map<String, int> _subjectData = {};
  int _totalStudyTime = 0;
  double _averageSessionTime = 0;
  int _weeklyProductivityScore = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  String? _productiveSubject;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get weeklyData => _weeklyData;
  Map<String, int> get monthlyData => _monthlyData;
  Map<String, int> get subjectData => _subjectData;
  int get totalStudyTime => _totalStudyTime;
  double get averageSessionTime => _averageSessionTime;
  int get weeklyProductivityScore => _weeklyProductivityScore;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  String? get productiveSubject => _productiveSubject;

  AnalyticsProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _analyticsService.init();
      await _streakService.init();
      await refreshData();
    } catch (e) {
      _error = 'Failed to initialize analytics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all analytics data
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _analyticsService.getWeeklyStudyTime(),
        _analyticsService.getMonthlyStudyTime(),
        _analyticsService.getStudyTimeBySubject(),
        _analyticsService.getTotalStudyTime(),
        _analyticsService.getAverageSessionDuration(),
        _analyticsService.getWeeklyProductivityScore(),
        _analyticsService.getMostProductiveSubject(),
      ]);

      _weeklyData = results[0] as Map<String, int>;
      _monthlyData = results[1] as Map<String, int>;
      _subjectData = results[2] as Map<String, int>;
      _totalStudyTime = results[3] as int;
      _averageSessionTime = results[4] as double;
      _weeklyProductivityScore = results[5] as int;
      _productiveSubject = results[6] as String?;

      // Update streak data
      _currentStreak = _streakService.getCurrentStreak();
      _longestStreak = _streakService.getLongestStreak();

      _isLoading = false;
      _error = null;
    } catch (e) {
      _error = 'Failed to load analytics: $e';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Get formatted total study time
  String getFormattedTotalTime() {
    final hours = _totalStudyTime ~/ 60;
    final minutes = _totalStudyTime % 60;

    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  /// Get formatted average session time
  String getFormattedAverageTime() {
    final minutes = _averageSessionTime.toInt();
    return '${minutes}m';
  }

  /// Get productivity level description
  String getProductivityLevel() {
    if (_weeklyProductivityScore >= 90) return 'Exceptional';
    if (_weeklyProductivityScore >= 75) return 'Excellent';
    if (_weeklyProductivityScore >= 60) return 'Good';
    if (_weeklyProductivityScore >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  /// Get productivity level color
  Color getProductivityColor() {
    if (_weeklyProductivityScore >= 90) return const Color(0xFF00FF88);
    if (_weeklyProductivityScore >= 75) return const Color(0xFF00CCF0);
    if (_weeklyProductivityScore >= 60) return const Color(0xFFFFA500);
    if (_weeklyProductivityScore >= 40) return const Color(0xFFFF6B6B);
    return const Color(0xFFFF3333);
  }

  /// Check if any data available
  bool get hasData {
    return _weeklyData.isNotEmpty || _totalStudyTime > 0;
  }
}
