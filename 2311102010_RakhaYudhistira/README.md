<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 7<br> Flutter </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Rakha Yudhistira</strong>
    <br>
    <strong>2311102010</strong>
    <br>
    <strong>S1 IF-11-REG05</strong>
  </p>
  <br />
  <h3>Dosen Pengampu :</h3>
  <p>
    <strong>Dedi Agung Prabowo, S.Kom., M.Kom</strong>
  </p>
  <br />
  <br />
  <h4>Asisten Praktikum :</h4>
  <strong>Apri Pandu Wicaksono </strong>
  <br>
  <strong>Hamka Zaenul Ardi</strong>
  <br />
  <h3>LABORATORIUM HIGH PERFORMANCE <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026 </h3>
</div>

<hr>


# Dasar Teori

<p align="justify">
Flutter merupakan framework open-source yang dikembangkan oleh Google untuk membangun aplikasi mobile, web, dan desktop menggunakan satu basis kode (single codebase). Flutter menggunakan bahasa pemrograman Dart dan menyediakan berbagai widget yang memudahkan pengembangan antarmuka pengguna yang responsif, interaktif, dan memiliki performa tinggi. Dalam pengembangan aplikasi modern, Flutter sering diintegrasikan dengan layanan Backend as a Service (BaaS) seperti Firebase dan Supabase untuk mempercepat proses pembangunan aplikasi tanpa perlu mengelola server secara mandiri. Firebase menyediakan berbagai layanan seperti Authentication, Cloud Firestore, Cloud Storage, dan Firebase Cloud Messaging (FCM), sedangkan Supabase menawarkan layanan Authentication, Database PostgreSQL, Storage, Realtime, dan API otomatis yang memudahkan pengelolaan data aplikasi.
</p>

<p align='justify'>
Integrasi Flutter dengan Firebase dan Supabase memungkinkan pengembang memanfaatkan keunggulan kedua platform secara bersamaan. Flutter berfungsi sebagai frontend yang menangani tampilan dan interaksi pengguna, Firebase dapat digunakan untuk layanan notifikasi dan autentikasi, sementara Supabase berperan sebagai backend utama yang mengelola penyimpanan data menggunakan PostgreSQL. Dengan kombinasi tersebut, aplikasi dapat memiliki sistem yang lebih fleksibel, efisien, dan mudah dikembangkan karena mampu memanfaatkan fitur real-time, autentikasi pengguna, manajemen data, serta layanan cloud yang mendukung kebutuhan aplikasi modern.
</p>

# Modul 7
## Source Code main.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Supabase (PASTIKAN URL & KEY DIISI)
  await Supabase.initialize(
    url: 'https://byaonszlaaogsrzugagg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5YW9uc3psYWFvZ3NyenVnYWdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNDc4ODQsImV4cCI6MjA5NjgyMzg4NH0.-L0nwA2dKwhXhSnWy-i3ifbeIPuSf5H1El8rHax22UU',
  );

  // Inisialisasi Notifikasi Lokal
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
```
## Source Code auth.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi sukses! Silakan login.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.assignment_turned_in, size: 72, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'Task Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manajemen Tugas Kuliah & Praktikum',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Mahasiswa',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        onPressed: _login,
                        child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _register,
                child: const Text('Mahasiswa Baru? Daftar di sini', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

## Source Code home.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'form.dart';
import 'auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await _supabase.from('tasks').select().order('course_name', ascending: true);
    setState(() {
      _tasks = response;
    });
  }

  Future<void> _deleteItem(String id, String taskName) async {
    await _supabase.from('tasks').delete().eq('id', id);
    NotificationService.showNotification(
      title: 'Tugas Selesai!',
      body: 'Mantap, "$taskName" sudah dihapus dari daftar.',
    );
    _fetchData();
  }

  Future<void> _showDeleteConfirmation(String id, String taskName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Tugas?'),
          content: Text('Apakah tugas "$taskName" sudah selesai dan ingin dihapus?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Ya, Hapus', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id, taskName);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text('Daftar Tugas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('Kosong! Waktunya santai.', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final item = _tasks[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.deepPurple),
                    ),
                    title: Text(item['task_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(item['course_name'], style: TextStyle(color: Colors.deepPurple.shade300, fontWeight: FontWeight.w500)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.orangeAccent, size: 28),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(item: item)));
                            _fetchData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                          onPressed: () => _showDeleteConfirmation(item['id'], item['task_name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
          _fetchData();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tugas Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
```
## Source Code form.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class FormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const FormScreen({super.key, this.item});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _taskController = TextEditingController();
  final _courseController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _taskController.text = widget.item!['task_name'];
      _courseController.text = widget.item!['course_name'];
    }
  }

  Future<void> _saveData() async {
    final userId = _supabase.auth.currentUser!.id;
    final task = _taskController.text;
    final course = _courseController.text;

    if (widget.item == null) {
      await _supabase.from('tasks').insert({
        'user_id': userId,
        'task_name': task,
        'course_name': course,
      });
      NotificationService.showNotification(
        title: 'Tugas Ditambahkan', 
        body: 'Semangat mengerjakan $task!'
      );
    } else {
      await _supabase.from('tasks').update({
        'task_name': task,
        'course_name': course,
      }).eq('id', widget.item!['id']);
      NotificationService.showNotification(
        title: 'Tugas Diperbarui', 
        body: 'Detail tugas $task berhasil diubah.'
      );
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text(widget.item == null ? 'Tambah Tugas' : 'Edit Tugas', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _taskController, 
              decoration: InputDecoration(
                labelText: 'Nama Tugas',
                hintText: 'Contoh: Laporan Modul 7...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _courseController, 
              decoration: InputDecoration(
                labelText: 'Mata Kuliah',
                hintText: 'Contoh: Pemrograman Mobile...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              )
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: _saveData, 
                child: const Text('Simpan Tugas', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
## Source Code notification_service.dart
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
    );
  }

  static Future showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_channel',
      'Task Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
```
# Screenshots Output
<img src="ssauth.png" alt="preview">
<img src="sstambah.png" alt="preview">
<img src="sshome.png" alt="preview">
<img src="ssedit.png" alt="preview">
<img src="sshapus.png" alt="preview">
<img src="ssdb.png" alt="preview">
<img src="sstable.png" alt="preview">

# Penjelasan
<p align="justify">
Kode di atas merupakan aplikasi Task Tracker berbasis Flutter yang terintegrasi dengan Supabase sebagai backend dan Flutter Local Notifications untuk notifikasi lokal. Pada bagian AuthScreen, pengguna dapat melakukan registrasi dan login menggunakan email serta password melalui fitur Authentication Supabase. Setelah berhasil login, pengguna diarahkan ke HomeScreen yang menampilkan daftar tugas yang tersimpan pada tabel tasks di database Supabase. Pengguna dapat menambahkan, mengubah, dan menghapus tugas melalui FormScreen, di mana setiap data tugas terdiri dari nama tugas dan mata kuliah. Seluruh data disimpan dan dikelola menggunakan operasi CRUD (Create, Read, Update, Delete) pada database Supabase. Selain itu, aplikasi memanfaatkan NotificationService untuk menampilkan notifikasi lokal saat tugas berhasil ditambahkan, diperbarui, atau dihapus. Pada file main.dart, dilakukan inisialisasi Supabase dan layanan notifikasi sebelum aplikasi dijalankan, sehingga seluruh fitur autentikasi, manajemen data, dan notifikasi dapat berfungsi dengan baik.
</p>