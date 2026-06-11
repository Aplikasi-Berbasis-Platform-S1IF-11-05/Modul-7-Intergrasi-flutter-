import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'order_form_screen.dart';
import '../profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CollectionReference orders = FirebaseFirestore.instance.collection(
    'pesanan_lumubi',
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _initNotifikasi();
    _dengarkanPerubahanCRUD();
  }

  void _initNotifikasi() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  void _dengarkanPerubahanCRUD() {
    orders.snapshots().listen((snapshot) {
      if (_isInit) {
        _isInit = false;
        return;
      }
      for (var change in snapshot.docChanges) {
        // Notifikasi saat ada pesanan BARU (Create)
        if (change.type == DocumentChangeType.added) {
          _tampilkanNotifikasiPonsel(
            'Pesanan Baru Masuk!',
            '${change.doc['nama']} memesan ${change.doc['jumlah_box']} box Lumubi.',
          );
        }
        // Notifikasi saat status pesanan DIUBAH (Update)
        else if (change.type == DocumentChangeType.modified) {
          _tampilkanNotifikasiPonsel(
            'Status Pesanan Diperbarui',
            'Pesanan atas nama ${change.doc['nama']} sekarang berstatus: ${change.doc['status']}',
          );
        }
      }
    });
  }

  Future<void> _tampilkanNotifikasiPonsel(String judul, String isi) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'crud_channel',
          'Notifikasi CRUD',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Perbaikan 2: Menggunakan Named Parameter untuk show
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: judul,
      body: isi,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> hapusPesanan(String docId) async {
    await orders.doc(docId).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pesanan Dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Lumubi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orders.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(doc['nama']),
                  subtitle: Text(
                    'Jumlah: ${doc['jumlah_box']} Box | Status: ${doc['status']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusPesanan(doc.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderFormScreen(docId: doc.id, currentData: doc),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderFormScreen()),
          );
        },
      ),
    );
  }
}
