import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7C4DFF);
  static const Color secondary = Color(0xFF00E5FF);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color error = Color(0xFFCF6679);
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE91E63);
  static const Color warning = Color(0xFFFF9800);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: surface,
          surfaceContainerHighest: surfaceVariant,
          primary: primary,
          secondary: secondary,
          error: error,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceVariant,
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceVariant,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceVariant,
          selectedItemColor: primary,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white60),
          hintStyle: const TextStyle(color: Colors.white38),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceVariant,
          selectedColor: primary.withOpacity(0.3),
          labelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.white12,
          thickness: 1,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white70),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
          labelLarge: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white60),
        ),
      );
}

const List<int> accountColors = [
  0xFF1976D2, // Blue
  0xFF388E3C, // Green
  0xFFD32F2F, // Red
  0xFFF57C00, // Orange
  0xFF7B1FA2, // Purple
  0xFF00838F, // Cyan
  0xFF5D4037, // Brown
  0xFF455A64, // Blue Grey
  0xFF558B2F, // Light Green
  0xFF6A1B9A, // Deep Purple
  0xFF00695C, // Teal
  0xFFC62828, // Dark Red
];
