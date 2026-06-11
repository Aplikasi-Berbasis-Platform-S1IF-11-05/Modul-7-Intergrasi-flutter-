// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'services/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Inisialisasi Supabase menggunakan .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Inisialisasi Notifications
  await NotificationService().initNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Task Management App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/tasks': (context) => const TaskListScreen(),
            '/splash': (context) => const SplashScreen(),
          },
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Monochrome Palette
    final primaryColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? const Color(0xFF111111) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      
      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, color: primaryColor),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w800, color: primaryColor),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: primaryColor),
        labelSmall: GoogleFonts.jetBrainsMono(color: isDark ? Colors.white54 : Colors.black54),
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w900,
          fontSize: 24,
          color: primaryColor,
          letterSpacing: -1,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Sharp edges
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero, // Sharp edges
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(),
        hintStyle: GoogleFonts.jetBrainsMono(fontSize: 14),
      ),

      cardTheme: CardThemeData(
        color: backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        onPrimary: backgroundColor,
        surface: surfaceColor,
      ),
    );
  }
}
