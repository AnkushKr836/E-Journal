import 'package:flutter/material.dart';

class AppTheme {
  // Slate & Indigo palette matching the sleek, classic README aesthetic
  static const Color primaryDark = Color(0xFF6366F1); // Indigo accent
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF334155); // Slate 700

  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF1F5F9); // Slate 100

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: Color(0xFF38BDF8), // Sky blue
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSurface: Color(0xFFF8FAFC),
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: false,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: surfaceDark,
      selectedIconTheme: IconThemeData(color: primaryDark),
      unselectedIconTheme: IconThemeData(color: Color(0xFF94A3B8)),
      indicatorColor: Color(0xFF312E81),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: Color(0xFF0284C7),
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSurface: Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: false,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: surfaceLight,
      selectedIconTheme: IconThemeData(color: primaryLight),
      unselectedIconTheme: IconThemeData(color: Color(0xFF64748B)),
      indicatorColor: Color(0xFFE0E7FF),
    ),
  );
}
