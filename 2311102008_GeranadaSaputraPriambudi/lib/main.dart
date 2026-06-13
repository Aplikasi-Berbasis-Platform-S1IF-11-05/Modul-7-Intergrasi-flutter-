//Geranada Saputra Priambudi 2311102008
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: the user must configure firebase using `flutterfire configure` 
  // or add google-services.json manually for this to work.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
    // Ensure the app doesn't crash if Firebase isn't configured yet
  }

  // Initialize Local Notifications
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Modern standard font
      ),
      debugShowCheckedModeBanner: false,
      home: AuthStateHandler(),
    );
  }
}

// Handles routing based on whether the user is logged in
class AuthStateHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // We check if the user is currently logged in.
    // If Firebase isn't configured, this will throw, so we use a simple stream builder
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return HomeScreen();
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
