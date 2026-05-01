import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF5A00);
  static const Color primaryDark = Color(0xFFD94E00);
  static const Color primaryLight = Color(0xFFFF7A30);
  static const Color black = Color(0xFF0F0F0F);
  static const Color dark = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF222222);
  static const Color border = Color(0xFF333333);
  static const Color white = Color(0xFFF5F0EB);
  static const Color muted = Color(0xFF888888);
  static const Color green = Color(0xFF22C55E);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: blue,
        surface: card,
        error: red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: white,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: dark,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: black,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary),
        ),
        labelStyle: const TextStyle(color: muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: dark,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
