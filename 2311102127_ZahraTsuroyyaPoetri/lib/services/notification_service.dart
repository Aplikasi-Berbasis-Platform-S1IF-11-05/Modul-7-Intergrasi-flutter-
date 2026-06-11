import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings);

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pinspiration_channel',
      'Pinspiration Notification',
      channelDescription:
          'Notification for CRUD activities',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}