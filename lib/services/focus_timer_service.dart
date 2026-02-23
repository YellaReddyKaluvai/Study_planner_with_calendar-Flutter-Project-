import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/study_session.dart';
import 'analytics_service.dart';

/// Service to manage Pomodoro/Focus timer sessions
class FocusTimerService extends ChangeNotifier {
  static final FocusTimerService _instance = FocusTimerService._internal();
  factory FocusTimerService() => _instance;
  FocusTimerService._internal();

  final AnalyticsService _analyticsService = AnalyticsService();

  // Timer states
  bool _isRunning = false;
  int _timeRemaining = 0; // in seconds
  int _sessionDuration = 1500; // Default 25 minutes (Pomodoro)
  String _currentSubject = 'Study';
  Timer? _timer;

  // Getters
  bool get isRunning => _isRunning;
  int get timeRemaining => _timeRemaining;
  int get sessionDuration => _sessionDuration;
  String get currentSubject => _currentSubject;
  double get progress => (_sessionDuration - _timeRemaining) / _sessionDuration;
  String get formattedTime {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Initialize the service
  Future<void> init() async {
    await _analyticsService.init();
    _timeRemaining = _sessionDuration;
  }

  /// Start the focus timer
  void startTimer({int? customDuration, String? subject}) {
    if (_isRunning) return;

    if (customDuration != null) {
      _sessionDuration = customDuration;
      _timeRemaining = customDuration;
    }

    if (subject != null) {
      _currentSubject = subject;
    }

    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        completeSession();
      }
    });
  }

  /// Pause the timer
  void pauseTimer() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  /// Resume the timer
  void resumeTimer() {
    if (_isRunning || _timeRemaining == 0) return;

    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        completeSession();
      }
    });
  }

  /// Stop/Reset the timer
  void stopTimer() {
    _isRunning = false;
    _timer?.cancel();
    _timeRemaining = _sessionDuration;
    notifyListeners();
  }

  /// Complete the session and record it
  Future<void> completeSession({int? tasksCompleted, String? notes}) async {
    _isRunning = false;
    _timer?.cancel();

    final duration = _sessionDuration - _timeRemaining;
    final durationMinutes = (duration / 60).ceil();

    // Record session in analytics
    try {
      final session = StudySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        minutes: durationMinutes,
        subject: _currentSubject,
        taskId: 'focus_session',
        startTime: DateTime.now().subtract(Duration(seconds: duration)),
        endTime: DateTime.now(),
        notes: notes,
        tasksCompleted: tasksCompleted,
        focusQuality: 0.9,
      );

      await _analyticsService.recordSession(session);
    } catch (e) {
      print("Error recording session: $e");
    }

    // Reset for next session
    _timeRemaining = _sessionDuration;
    notifyListeners();
  }

  /// Set custom timer duration
  void setDuration(int seconds) {
    if (!_isRunning) {
      _sessionDuration = seconds;
      _timeRemaining = seconds;
      notifyListeners();
    }
  }

  /// Quick preset: 25 minutes (Pomodoro)
  void setPomodoro() => setDuration(1500);

  /// Quick preset: 50 minutes (Deep work)
  void setDeepWork() => setDuration(3000);

  /// Quick preset: 5 minutes (Quick break)
  void setQuickBreak() => setDuration(300);

  /// Add time to current session
  void addTime(int seconds) {
    _sessionDuration += seconds;
    _timeRemaining += seconds;
    notifyListeners();
  }

  /// Reduce time from current session
  void reduceTime(int seconds) {
    _sessionDuration = (_sessionDuration - seconds).clamp(60, 99999);
    if (!_isRunning) {
      _timeRemaining = _sessionDuration;
    }
    notifyListeners();
  }

  /// Cleanup
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Timer preset configurations
class TimerPreset {
  final String name;
  final int seconds;
  final String icon;
  final String description;

  TimerPreset({
    required this.name,
    required this.seconds,
    required this.icon,
    required this.description,
  });

  static final presets = [
    TimerPreset(
      name: 'Quick Focus',
      seconds: 300, // 5 minutes
      icon: '⚡',
      description: 'Quick revision',
    ),
    TimerPreset(
      name: 'Pomodoro',
      seconds: 1500, // 25 minutes
      icon: '🍅',
      description: 'Classic focus session',
    ),
    TimerPreset(
      name: 'Deep Work',
      seconds: 3000, // 50 minutes
      icon: '🧠',
      description: 'Extended focus',
    ),
    TimerPreset(
      name: 'Marathon',
      seconds: 5400, // 90 minutes
      icon: '💪',
      description: 'Intense study block',
    ),
  ];
}
