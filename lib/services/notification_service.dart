import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request Android permission (API 33+)
    if (!kIsWeb) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  Future<void> showSimpleNotification(String title, String body,
      {String? payload}) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      'study_channel',
      'Study Planner',
      channelDescription: 'Study planner task reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Shows a study reminder notification for a task
  Future<void> showTaskReminder(String taskTitle, String taskId) async {
    await showSimpleNotification(
      '📚 Study Reminder',
      'Time to study: $taskTitle',
      payload: taskId,
    );
  }

  /// Cancels a specific notification by id
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  /// Cancels all notifications
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// Shows streak congratulation notification
  Future<void> showStreakNotification(int streakDays) async {
    await showSimpleNotification(
      '🔥 Study Streak!',
      'You\'re on a $streakDays-day study streak! Keep it up!',
    );
  }

  /// Shows XP earned notification
  Future<void> showXPNotification(int xp, int totalXP) async {
    await showSimpleNotification(
      '⭐ XP Earned!',
      'You earned $xp XP! Total: $totalXP XP',
    );
  }
}
