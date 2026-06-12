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