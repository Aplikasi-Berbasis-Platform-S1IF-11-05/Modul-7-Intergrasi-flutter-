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
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginPage()
          : const HomePage(),
    );
  }
}