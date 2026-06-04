import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine_model.dart';

/// Mengendalikan sistem pengingat dan notifikasi lokal.
///
/// Class ini menangani izin akses, serta penjadwalan
/// notifikasi langsung maupun notifikasi terjadwal.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Menginisialisasi sistem notifikasi.
  ///
  /// Menyiapkan zona waktu lokal dan mengonfigurasi
  /// pengaturan dasar untuk antarmuka perangkat.
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings: settings);
  }

  /// Meminta persetujuan pengguna untuk menampilkan notifikasi.
  ///
  /// Wajib dipanggil pada perangkat modern agar
  /// sistem mengizinkan aplikasi memunculkan pengingat.
  static Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  /// Memunculkan notifikasi secara instan.
  ///
  /// Digunakan untuk memberi umpan balik cepat kepada pengguna
  /// setelah melakukan aksi seperti menyimpan atau menghapus.
  static Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'crud_channel', 
      'CRUD Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: DateTime.now().millisecond, 
      title: title, 
      body: body, 
      notificationDetails: details,
    );
  }

  /// Memasang alarm pengingat minum obat.
  ///
  /// Notifikasi akan berbunyi tepat pada jam yang telah
  /// ditentukan dalam data jadwal obat.
  static Future<void> scheduleMedicineNotification(MedicineModel medicine) async {
    final now = tz.TZDateTime.now(tz.local);
    final parts = medicine.time.split(':');
    if (parts.length != 2) return;
    
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'schedule_channel', 
      'Medicine Alarms',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    final int notificationId = medicine.id.hashCode;

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Waktunya Minum Obat',
      body: 'Saatnya meminum ${medicine.name} (${medicine.dose}).',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Menghapus jadwal alarm yang sudah terpasang.
  ///
  /// Dipanggil ketika obat telah selesai diminum
  /// atau saat jadwal dihapus dari sistem.
  static Future<void> cancelNotification(String medicineId) async {
    await _notificationsPlugin.cancel(id: medicineId.hashCode);
  }
}