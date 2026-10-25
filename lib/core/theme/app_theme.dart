import 'package:flutter/material.dart';

class AppTheme {
  // Futuristic Cyber-Clinical Dark Palette
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1F2937);

  // Pure AMOLED Black Palette
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF050505);
  static const Color amoledCard = Color(0xFF101010);

  // Clean Medical Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color deepNavy = Color(0xFF0F172A);

  static ThemeData getLightTheme(Color accentColor, {bool highContrast = false}) {
    final primary = accentColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: primary,
        surface: lightSurface,
        surfaceContainerHighest: lightCard,
        onSurface: deepNavy,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: lightSurface,
        foregroundColor: deepNavy,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        titleTextStyle: TextStyle(
          color: deepNavy,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: highContrast ? 2 : 0.5,
        color: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: highContrast ? Colors.black : const Color(0xFFE2E8F0), width: highContrast ? 2 : 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme(Color accentColor, {bool isAmoled = false, bool highContrast = false}) {
    final primary = accentColor;
    final bg = isAmoled ? amoledBackground : darkBackground;
    final surface = isAmoled ? amoledSurface : darkSurface;
    final card = isAmoled ? amoledCard : darkCard;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: primary,
        surface: surface,
        surfaceContainerHighest: card,
        onSurface: const Color(0xFFF9FAFB),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: highContrast ? Colors.white : primary.withValues(alpha: 0.25),
            width: highContrast ? 2 : 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Backwards compatibility getters
  static ThemeData get lightTheme => getLightTheme(const Color(0xFF3B82F6));
  static ThemeData get darkTheme => getDarkTheme(const Color(0xFF06B6D4));
}
