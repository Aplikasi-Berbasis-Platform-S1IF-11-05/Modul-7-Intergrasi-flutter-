// NIM: 2311102155
// Nama: Naya Putwi Setiasih
// Modul 7 - Integrasi Flutter Firebase/Supabase (Notes App CRUD)
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; 

import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'services/firebase_service.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase belum dikonfigurasi. Silakan jalankan 'flutterfire configure'. Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas 7 - Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Firebase.apps.isEmpty
          ? const Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Firebase belum dikonfigurasi atau inisialisasi gagal.\nSilakan jalankan 'flutterfire configure' dan uncomment baris 'options: DefaultFirebaseOptions.currentPlatform' di main.dart.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            )
          : AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final AppFirebaseService _firebaseService = AppFirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
