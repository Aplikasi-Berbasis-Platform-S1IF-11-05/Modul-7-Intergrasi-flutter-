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
    <strong>Aryo Tegar Sukarno</strong>
    <br>
    <strong>2311102018</strong>
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
Flutter adalah framework pengembangan aplikasi yang dibuat oleh Google dan digunakan untuk membangun aplikasi Android, iOS, web, maupun desktop melalui satu kode program yang sama menggunakan bahasa Dart. Untuk mendukung kebutuhan backend, Flutter dapat diintegrasikan dengan layanan seperti Firebase dan Supabase. Firebase menyediakan berbagai fitur seperti autentikasi pengguna, penyimpanan data, penyimpanan file, serta layanan notifikasi yang dikelola oleh Google. Sementara itu, Supabase merupakan platform backend berbasis PostgreSQL yang bersifat open-source dan menyediakan fitur autentikasi, manajemen basis data, penyimpanan berkas, serta pembaruan data secara real-time. Penggunaan Flutter bersama Firebase atau Supabase membantu mempercepat proses pengembangan aplikasi karena pengembang dapat fokus pada pembuatan fitur dan antarmuka tanpa perlu membangun sistem backend dari awal.</p>

# Modul 7
## Source Code main.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://obfpdlnebbdesfnuczna.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9iZnBkbG5lYmJkZXNmbnVjem5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNjY5MTIsImV4cCI6MjA5Njg0MjkxMn0.EQY6k-sDmq13TGI9KI6J4xJDwjWD10GAo1nfOnzlc3k',
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobHunt Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2647)), // Navy Blue
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
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
      backgroundColor: const Color(0xFF0A2647), // Solid Navy Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.work, size: 64, color: Color(0xFF0A2647)),
                const SizedBox(height: 16),
                const Text(
                  'JobHunt Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A2647)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kelola lamaran magang & kerjamu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Profesional',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A2647)))
                    : SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A2647),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _login,
                          child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _register,
                  child: const Text('Kandidat Baru? Buat Akun', style: TextStyle(color: Color(0xFF0A2647))),
                )
              ],
            ),
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
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await _supabase.from('job_applications').select().order('company_name', ascending: true);
    setState(() {
      _applications = response;
    });
  }

  Future<void> _deleteItem(String id, String company) async {
    await _supabase.from('job_applications').delete().eq('id', id);
    NotificationService.showNotification(
      title: 'Data Dihapus',
      body: 'Lamaran ke $company telah dihapus dari sistem.',
    );
    _fetchData();
  }

  Future<void> _showDeleteConfirmation(String id, String company) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Lamaran?'),
          content: Text('Hapus riwayat lamaran ke $company?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id, company);
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A2647),
        title: const Text('Daftar Lamaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _applications.isEmpty
          ? const Center(child: Text('Belum ada lamaran terkirim.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final item = _applications[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.shade100,
                      child: const Icon(Icons.business, color: Colors.amber),
                    ),
                    title: Text(item['company_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(item['position'], style: const TextStyle(color: Color(0xFF0A2647))),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(item: item)));
                            _fetchData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmation(item['id'], item['company_name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        foregroundColor: const Color(0xFF0A2647),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
          _fetchData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data', style: TextStyle(fontWeight: FontWeight.bold)),
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
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _companyController.text = widget.item!['company_name'];
      _positionController.text = widget.item!['position'];
    }
  }

  Future<void> _saveData() async {
    final userId = _supabase.auth.currentUser!.id;
    final company = _companyController.text;
    final position = _positionController.text;

    if (widget.item == null) {
      await _supabase.from('job_applications').insert({
        'user_id': userId,
        'company_name': company,
        'position': position,
      });
      NotificationService.showNotification(
        title: 'Lamaran Disimpan', 
        body: 'Semoga sukses dengan lamaran $position di $company!'
      );
    } else {
      await _supabase.from('job_applications').update({
        'company_name': company,
        'position': position,
      }).eq('id', widget.item!['id']);
      NotificationService.showNotification(
        title: 'Data Diperbarui', 
        body: 'Data lamaran di $company berhasil diubah.'
      );
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A2647),
        title: Text(widget.item == null ? 'Input Lamaran' : 'Edit Lamaran', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _companyController, 
              decoration: const InputDecoration(
                labelText: 'Nama Perusahaan',
                hintText: 'Masukkan nama perusahaan...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _positionController, 
              decoration: const InputDecoration(
                labelText: 'Posisi yang Dilamar',
                hintText: 'Cth: Software Engineer Intern, Data Analyst...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              )
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: const Color(0xFF0A2647),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveData, 
                child: const Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Source Code notification_service
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
      'jobhunt_channel',
      'JobHunt Tracker Notification',
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
<img src="auth.png" alt="preview">
<img src="dashboard.png" alt="preview">
<img src="input.png" alt="preview">
<img src="edit.png" alt="preview">
<img src="hapus.png" alt="preview">
<img src="supabase.png" alt="preview">

# Penjelasan
<p align="justify">
Kode di atas merupakan aplikasi JobHunt Tracker berbasis Flutter yang digunakan untuk mengelola data lamaran kerja atau magang. Aplikasi ini menggunakan Supabase sebagai backend untuk autentikasi pengguna dan penyimpanan data, serta Flutter Local Notifications untuk menampilkan notifikasi kepada pengguna. Pada saat aplikasi dijalankan, sistem melakukan inisialisasi Supabase dan layanan notifikasi, kemudian menampilkan halaman login dan registrasi. Setelah pengguna berhasil masuk, aplikasi akan menampilkan daftar lamaran kerja yang tersimpan pada database Supabase. Pengguna dapat melakukan operasi CRUD (Create, Read, Update, Delete), yaitu menambahkan, melihat, mengubah, dan menghapus data lamaran yang berisi nama perusahaan dan posisi yang dilamar. Setiap perubahan data, seperti penambahan, pembaruan, atau penghapusan lamaran, akan memunculkan notifikasi lokal sebagai bentuk konfirmasi kepada pengguna. Dengan demikian, aplikasi ini mengintegrasikan teknologi Flutter, Supabase, dan notifikasi lokal untuk membantu pengguna mencatat serta memantau proses pencarian kerja atau magang secara lebih efektif dan terorganisir.
</p>