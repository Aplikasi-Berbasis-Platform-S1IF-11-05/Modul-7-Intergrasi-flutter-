import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'pages/home/home_page.dart';
import 'pages/auth/login_page.dart';

/// Memulai eksekusi aplikasi Flutter.
///
/// Fungsi ini melakukan inisialisasi Firebase dan konfigurasi
/// notifikasi sebelum memuat antarmuka pengguna utama.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  runApp(const RawatinApp());
}

/// Menjadi kerangka utama dari aplikasi.
///
/// Widget ini mengatur tema dasar dan mendaftarkan
/// halaman pertama yang akan diakses pengguna.
class RawatinApp extends StatelessWidget {
  const RawatinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rawat.in App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

/// Mengarahkan pengguna ke halaman yang tepat.
///
/// Widget ini memantau status sesi Firebase untuk menampilkan
/// halaman beranda jika sudah login, atau halaman masuk jika belum.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return const HomePage();
        return const LoginPage();
      },
    );
  }
}