<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 7 <br> FLUTTER </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Grashela Ayudia Prameswari</strong>
    <br>
    <strong>2311102318</strong>
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
Flutter merupakan framework pengembangan aplikasi mobile lintas platform yang dikembangkan oleh Google dengan menggunakan bahasa pemrograman Dart. Flutter memungkinkan pengembang membuat aplikasi untuk Android, iOS, web, dan desktop dari satu basis kode yang sama. Dalam pengembangan aplikasi modern, Flutter sering diintegrasikan dengan layanan Backend as a Service (BaaS) seperti Firebase dan Supabase untuk mempermudah pengelolaan data, autentikasi pengguna, penyimpanan file, serta sinkronisasi data secara real-time tanpa perlu membangun server backend secara mandiri.
</p>
<p align="justify">
Firebase dan Supabase merupakan platform layanan backend yang menyediakan berbagai fitur untuk mendukung pengembangan aplikasi. Firebase dikembangkan oleh Google dan menawarkan layanan seperti Authentication, Cloud Firestore, Realtime Database, dan Cloud Storage. Sementara itu, Supabase merupakan platform open-source yang menggunakan PostgreSQL sebagai basis data utama dan menyediakan fitur autentikasi, database real-time, penyimpanan berkas, serta API otomatis. Integrasi Flutter dengan Firebase atau Supabase memungkinkan aplikasi berinteraksi secara langsung dengan layanan backend sehingga proses pengelolaan data menjadi lebih efisien, aman, dan mudah diimplementasikan dalam pengembangan aplikasi modern.
</p>


# Tugas 7 - Flutter
## 1. Source Code main.dart
```
// 2311102318
// Grashela Ayudia Prameswari
// S1IF-11-05
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Coffee Order",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.pink,
          ),
        ),
      ),
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginPage()
          : const HomePage(),
    );
  }
}
```

## 2. Source Code home_page.dart
```
// 2311102318
// Grashela Ayudia Prameswari
// S1IF-11-05
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final supabase = Supabase.instance.client;

  List orders = [];

  void showCustomSnackBar({
  required String message,
  required IconData icon,
  required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        elevation: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
```
**Kode Lengkap : [lib/home_page.dart](lib/home_page.dart)**

## 3. Source Code login_page.dart
```
// 2311102318
// Grashela Ayudia Prameswari
// S1IF-11-05
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final email = TextEditingController();
  final password = TextEditingController();

  Future login() async {
    try {

      await Supabase.instance.client.auth.signInWithPassword(
        email: email.text,
        password: password.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );

    }
  }
```
**Kode Lengkap : [lib/login_page.dart](lib/login_page.dart)**

## 4. Source Code notification_service.dart
```
// 2311102318
// Grashela Ayudia Prameswari
// S1IF-11-05
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
      'coffee_channel',
      'Coffee Notification',
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

## 5. Source Code register_page.dart
```
// 2311102318
// Grashela Ayudia Prameswari
// S1IF-11-05
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final email = TextEditingController();
  final password = TextEditingController();

  Future register() async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email.text,
        password: password.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register berhasil"))
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: register,
              child: const Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}
```
**Kode Lengkap : [lib/register_page.dart](lib/register_page.dart)**

# Output

> Tambahkan screenshot hasil akhir aplikasi (tema **pink**) dan dashboard Supabase yang sudah berhasil diintegrasikan di sini.

<!-- Contoh:
![Login](screenshot/login.jpeg)
![Home](screenshot/home.jpeg)
![Supabase Dashboard](screenshot/supabase.png)
-->

# Penjelasan
<p align="justify">
Aplikasi Coffee Order merupakan aplikasi mobile berbasis Flutter yang menggunakan Supabase sebagai backend untuk mengelola data secara online. Aplikasi ini menerapkan fitur Authentication berupa registrasi dan login pengguna menggunakan email dan password, sehingga setiap pengguna dapat mengakses sistem secara aman. Setelah berhasil login, pengguna dapat melakukan operasi CRUD (Create, Read, Update, Delete) pada data pesanan kopi yang tersimpan di database Supabase. Data yang dikelola meliputi nama kopi, ukuran (size), dan jumlah pesanan. Selain itu, aplikasi juga dilengkapi dengan notifikasi CRUD yang muncul baik dalam bentuk notifikasi mengambang (SnackBar) di dalam aplikasi maupun notifikasi pada panel notifikasi Android menggunakan package flutter_local_notifications, sehingga pengguna memperoleh informasi setiap kali berhasil menambahkan, mengubah, atau menghapus data. Berbeda dengan tema coffee shop berwarna coklat pada umumnya, aplikasi ini menggunakan tema warna **pink** yang diterapkan pada AppBar, tombol, FloatingActionButton, serta seluruh komponen utama antarmuka sehingga tampilan aplikasi terlihat lebih lembut dan menarik. Dengan antarmuka yang sederhana dan tema pink, aplikasi ini menunjukkan implementasi integrasi Flutter dengan Supabase untuk autentikasi, penyimpanan data online, serta pengelolaan data secara real-time.
</p>
