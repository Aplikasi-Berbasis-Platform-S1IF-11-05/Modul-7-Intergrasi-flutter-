/// NIM: 2311102051
/// Nama: Muhammad Aulia Muzzaki Nugraha
/// Kelas: Praktikum Aplikasi Berbasis Platform

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  // Jika key belum diganti, Supabase.initialize akan gagal. Kami menangkap error
  // agar aplikasi tetap dapat terbuka dan memandu pengguna untuk mengisi konfigurasi.
  bool isSupabaseInitialized = false;
  try {
    if (Config.supabaseUrl != "YOUR_SUPABASE_URL" &&
        Config.supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY") {
      await Supabase.initialize(
        url: Config.supabaseUrl,
        anonKey: Config.supabaseAnonKey,
      );
      isSupabaseInitialized = true;
    }
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }

  // Inisialisasi Local Notifications
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint("Error initializing Notification Service: $e");
  }

  runApp(MyApp(isSupabaseInitialized: isSupabaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isSupabaseInitialized;

  const MyApp({super.key, required this.isSupabaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigoAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
      ),
      home: isSupabaseInitialized
          ? const AuthGateway()
          : const ConfigurationErrorScreen(),
    );
  }
}

// Gateway to automatically switch screens between Auth and Home based on login state
class AuthGateway extends StatelessWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.indigoAccent),
            ),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

// Fallback screen if the user has not entered their credentials in config.dart
class ConfigurationErrorScreen extends StatelessWidget {
  const ConfigurationErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 24),
              Text(
                'Konfigurasi Diperlukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Anda perlu memasukkan URL dan Anon Key Supabase Anda terlebih dahulu pada file config.dart.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Lokasi file:\nlib/config.dart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: Colors.indigoAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
