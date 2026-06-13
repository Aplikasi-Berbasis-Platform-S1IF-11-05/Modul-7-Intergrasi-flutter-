import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Request permissions for Android 13+
    if (!kIsWeb) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> showAddNotification(String bookTitle) async {
    await _showNotification(
      id: 1,
      title: '📚 Buku Ditambahkan',
      body: '"$bookTitle" berhasil ditambahkan ke koleksi Anda!',
      channelId: 'book_crud',
      channelName: 'Book CRUD Notifications',
    );
  }

  Future<void> showUpdateNotification(String bookTitle) async {
    await _showNotification(
      id: 2,
      title: '✏️ Buku Diperbarui',
      body: '"$bookTitle" berhasil diperbarui!',
      channelId: 'book_crud',
      channelName: 'Book CRUD Notifications',
    );
  }

  Future<void> showDeleteNotification(String bookTitle) async {
    await _showNotification(
      id: 3,
      title: '🗑️ Buku Dihapus',
      body: '"$bookTitle" telah dihapus dari koleksi Anda.',
      channelId: 'book_crud',
      channelName: 'Book CRUD Notifications',
    );
  }

  Future<void> showLoginNotification(String email) async {
    await _showNotification(
      id: 4,
      title: '👋 Selamat Datang!',
      body: 'Anda berhasil login sebagai $email',
      channelId: 'auth',
      channelName: 'Authentication Notifications',
    );
  }

  Future<void> showRegisterNotification(String email) async {
    await _showNotification(
      id: 5,
      title: '🎉 Registrasi Berhasil!',
      body: 'Akun $email berhasil dibuat. Selamat bergabung!',
      channelId: 'auth',
      channelName: 'Authentication Notifications',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifikasi untuk aplikasi Book Manager',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(id, title, body, details);
  }
}
