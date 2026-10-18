import 'package:flutter/material.dart';

class AppTheme {
  // --- Icy Blue Accents ---
  static const Color icyBlueAccent = Color(0xFF38BDF8); // Electric Icy Sky Blue
  static const Color icyBlueHover = Color(0xFF0EA5E9);
  static const Color icyBlueGlow = Color(0xFF7DD3FC);
  static const Color icyBlueDark = Color(0xFF0369A1);

  // --- Dark Palette: Dark Black + Midnight Blue Tones ---
  static const Color darkBackground = Color(0xFF050811); // Deepest Cosmic Black
  static const Color darkMidnightSurface = Color(0xFF0A1124); // Midnight Blue surface
  static const Color darkMidnightCard = Color(0xFF0F1B35); // Translucent Midnight Blue
  static const Color darkBorder = Color(0x2A38BDF8); // Subtle icy border

  // --- Light Palette: Icy White + Subtle Gray Tones ---
  static const Color lightBackground = Color(0xFFF1F5F9); // Crisp Icy Slate
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSubtleGray = Color(0xFFE2E8F0); // Subtle Mist Gray
  static const Color lightBorder = Color(0x60FFFFFF); // Frosted White Border

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: icyBlueAccent,
      secondary: icyBlueGlow,
      surface: darkMidnightSurface,
      onPrimary: darkBackground,
      onSurface: Color(0xFFF1F5F9),
      outline: darkBorder,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E293B),
      thickness: 1,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: icyBlueHover,
      secondary: icyBlueAccent,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSurface: Color(0xFF0F172A),
      outline: lightSubtleGray,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
  );
}
