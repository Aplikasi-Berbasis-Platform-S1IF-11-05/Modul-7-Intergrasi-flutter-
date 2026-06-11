import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color pinterestRed =
      Color(0xffE60023);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pinspiration',
      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xffFAFAFA),

        colorScheme: ColorScheme.fromSeed(
          seedColor: pinterestRed,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          foregroundColor: pinterestRed,
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: pinterestRed,
          foregroundColor: Colors.white,
        ),

        snackBarTheme: const SnackBarThemeData(
          backgroundColor: pinterestRed,
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}