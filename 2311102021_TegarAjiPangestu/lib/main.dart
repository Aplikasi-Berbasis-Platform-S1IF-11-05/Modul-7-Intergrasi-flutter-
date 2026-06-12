import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://hipccappyoxpvkvyiwbw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpcGNjYXBweW94cHZrdnlpd2J3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNTk4OTEsImV4cCI6MjA5NjgzNTg5MX0.A_2E8-V7Ye6VLrVrGoddyx7XvrHn-FD_-Tvt20jaL4k',
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wishlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: const Color(0xFFF4F7FE), // Warna background abu-abu kebiruan yang modern
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}