import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية للتطبيق المستوحاة من الإضاءة والراحة البصرية
  static const Color primaryAmber = Color(0xFFEAB308);
  static const Color primaryDarkAmber = Color(0xFFD97706);
  static const Color warmGlow = Color(0xFFFFFBEB);

  static const Color darkNavy = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardHighlight = Color(0xFF334155);

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;

  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4);

  /// السمة الفاتحة (Light Theme)
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDarkAmber,
        brightness: Brightness.light,
        primary: primaryDarkAmber,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFEF3C7),
        onPrimaryContainer: const Color(0xFF78350F),
        surface: lightCard,
        surfaceContainerLow: const Color(0xFFF1F5F9),
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryDarkAmber, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryDarkAmber,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// السمة الداكنة (Dark Theme)
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAmber,
        brightness: Brightness.dark,
        primary: primaryAmber,
        onPrimary: const Color(0xFF1E293B),
        primaryContainer: const Color(0xFF78350F),
        onPrimaryContainer: const Color(0xFFFEF3C7),
        surface: darkCard,
        surfaceContainerLow: darkCardHighlight,
      ),
      scaffoldBackgroundColor: darkNavy,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: darkCardHighlight, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkCardHighlight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkCardHighlight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryAmber, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryAmber,
          foregroundColor: const Color(0xFF0F172A),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
