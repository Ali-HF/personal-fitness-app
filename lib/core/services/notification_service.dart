import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService._internal();

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Request permissions on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    try {
      final androidPlatform = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        final granted = await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
    return false;
  }

  /// Schedule or show a reminder notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized || kIsWeb) {
      debugPrint('[Notification Preview] $title: $body');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'fitness_app_channel',
        'Daily Training & Export Reminders',
        channelDescription: 'Workout reminders and weekly export prompts',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Send the Sunday 8 PM Export Reminder
  Future<void> triggerSundayExportReminder() async {
    await showLocalNotification(
      id: 200,
      title: 'Sunday Review Ready 📋',
      body: 'Export this week for review to check your 7-day volume, soreness, and pace trends.',
      payload: 'export_review',
    );
  }

  /// Send Morning Workout Reminder
  Future<void> triggerMorningWorkoutReminder(String sessionTitle) async {
    await showLocalNotification(
      id: 100,
      title: 'Morning Training ☀️',
      body: 'Today\'s planned session: $sessionTitle. Ready to start?',
      payload: 'morning_workout',
    );
  }
}

