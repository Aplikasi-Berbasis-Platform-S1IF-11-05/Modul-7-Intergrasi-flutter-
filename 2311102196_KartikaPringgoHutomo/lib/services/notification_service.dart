//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // Meminta izin untuk Push Notification (penting untuk iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for Push Notifications');
    }

    // Mendapatkan token perangkat untuk testing via Firebase Console
    String? token = await _fcm.getToken();
    print("FCM Device Token: $token");

    // Menangani push notification ketika aplikasi di-foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Menerima pesan FCM di foreground!');
      if (message.notification != null) {
        print('Judul: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
      }
    });
  }
}
