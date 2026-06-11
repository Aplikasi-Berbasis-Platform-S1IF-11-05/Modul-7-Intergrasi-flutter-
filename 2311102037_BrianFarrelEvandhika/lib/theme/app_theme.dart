import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Theme curated color scheme
  static const Color backgroundColor = Color(0xFF0F0C20);
  static const Color surfaceColor = Color(0xFF181528);
  static const Color cardColor = Color(0xFF201B35);
  
  static const Color accentCyan = Color(0xFF00F2FE);
  static const Color accentPurple = Color(0xFF9D4EDD);
  static const Color accentPink = Color(0xFFFF007F);
  
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF9E9DB0);
  static const Color borderLight = Color(0xFF2E2A47);

  // Priority Colors
  static const Color priorityLow = Color(0xFF00C897);
  static const Color priorityMedium = Color(0xFFFFB300);
  static const Color priorityHigh = Color(0xFFFF4A4A);

  // Category Colors
  static const Color categoryWork = Color(0xFF4EA8DE);
  static const Color categoryPersonal = Color(0xFF9B5DE5);
  static const Color categoryShopping = Color(0xFFF15BB5);
  static const Color categoryHealth = Color(0xFF00F5D4);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentPurple,
        surface: surfaceColor,
        error: priorityHigh,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: priorityHigh),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight),
        ),
      ),
    );
  }

  // Get Priority Color helper
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
      default:
        return priorityLow;
    }
  }

  // Get Category Color helper
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return categoryWork;
      case 'personal':
        return categoryPersonal;
      case 'shopping':
        return categoryShopping;
      case 'health':
        return categoryHealth;
      default:
        return accentCyan;
    }
  }

  // Get Category Icon helper
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.favorite_border_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }
}
