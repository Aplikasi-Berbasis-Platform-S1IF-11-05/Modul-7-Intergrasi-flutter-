import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  final List<NotificationLog> _logs = [];
  List<NotificationLog> get logs => List.unmodifiable(_logs);

  static const String _logsKey = 'notification_logs_key';

  // Initialize notifications
  Future<void> init() async {
    if (_isInitialized) return;

    // Load saved notification logs
    await loadLogs();

    // Configure Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize OS-level local notifications: $e');
    }
  }

  // Load notification logs from shared preferences
  Future<void> loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsString = prefs.getString(_logsKey);
      if (logsString != null) {
        final List<dynamic> decoded = jsonDecode(logsString);
        _logs.clear();
        _logs.addAll(decoded.map((item) => NotificationLog.fromJson(item)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notification logs: $e');
    }
  }

  // Save notification logs to shared preferences
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_logs.map((log) => log.toJson()).toList());
      await prefs.setString(_logsKey, encoded);
    } catch (e) {
      debugPrint('Error saving notification logs: $e');
    }
  }

  // Trigger OS Notification & Add In-App Log
  Future<void> showNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    // 1. Add to In-App log
    final newLog = NotificationLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    
    _logs.insert(0, newLog); // Put newest on top
    notifyListeners();
    await _saveLogs();

    // 2. Trigger OS-level Notification if initialized
    if (!_isInitialized) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'taskflow_crud_channel',
      'TaskFlow Activity',
      channelDescription: 'Notifications for task management activities',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _localNotifications.show(
        newLog.hashCode,
        title,
        message,
        platformDetails,
        payload: type,
      );
    } catch (e) {
      debugPrint('Error showing local OS notification: $e');
    }
  }

  // Clear notification logs
  Future<void> clearLogs() async {
    _logs.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logsKey);
  }
}
