// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'System Log Notifications',
          channelDescription: 'Technical log updates for task operations',
          defaultColor: Colors.black,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'System Log Group',
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> showTaskCreatedNotification(String taskTitle) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'TASK_ENTRY::CREATED',
        body: 'LOG_ID: ${taskTitle.toUpperCase()} HAS_BEEN_INITIALIZED',
        notificationLayout: NotificationLayout.Default,
        color: Colors.black,
      ),
    );
  }

  Future<void> showTaskUpdatedNotification(String taskTitle) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'TASK_ENTRY::UPDATED',
        body: 'LOG_ID: ${taskTitle.toUpperCase()} DATA_SYNC_COMPLETE',
        notificationLayout: NotificationLayout.Default,
        color: Colors.black,
      ),
    );
  }

  Future<void> showTaskDeletedNotification(String taskTitle) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'TASK_ENTRY::TERMINATED',
        body: 'LOG_ID: ${taskTitle.toUpperCase()} REMOVED_FROM_DATABASE',
        notificationLayout: NotificationLayout.Default,
        color: Colors.black,
      ),
    );
  }

  Future<void> showTaskCompletedNotification(String taskTitle) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'TASK_ENTRY::SUCCESS',
        body: 'LOG_ID: ${taskTitle.toUpperCase()} STATUS::COMPLETED',
        notificationLayout: NotificationLayout.Default,
        color: Colors.black,
      ),
    );
  }

  Future<void> showErrorNotification(String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'CRITICAL_SYSTEM_ERROR',
        body: 'EXCEPTION_LOG: ${message.toUpperCase()}',
        notificationLayout: NotificationLayout.Default,
        color: Colors.red,
      ),
    );
  }

  Future<void> showAuthNotification(String title, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'AUTH_SERVICE::${title.replaceAll(' ', '_').toUpperCase()}',
        body: message.toUpperCase(),
        notificationLayout: NotificationLayout.Default,
        color: Colors.black,
      ),
    );
  }
}
