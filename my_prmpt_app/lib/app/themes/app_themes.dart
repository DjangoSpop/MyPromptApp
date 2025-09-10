// lib/app/themes/app_themes.dart
import 'package:flutter/material.dart';

/// Application themes configuration with Discord-like gamified UI
class AppThemes {
  // Discord-inspired color palette
  static const Color discordBlurple = Color(0xFF5865F2);
  static const Color discordGreen = Color(0xFF57F287);
  static const Color discordYellow = Color(0xFFFEE75C);
  static const Color discordFuchsia = Color(0xFFEB459E);
  static const Color discordRed = Color(0xFFED4245);
  static const Color discordWhite = Color(0xFFFFFFFF);
  static const Color discordBlack = Color(0xFF23272A);
  static const Color discordDarkGrey = Color(0xFF2C2F33);
  static const Color discordLightGrey = Color(0xFF99AAB5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Whitney', // Discord's font family
      brightness: Brightness.light,
      primaryColor: discordBlurple,
      scaffoldBackgroundColor: const Color(0xFFF2F3F5),
      colorScheme: ColorScheme.fromSeed(
        seedColor: discordBlurple,
        brightness: Brightness.light,
        primary: discordBlurple,
        secondary: discordGreen,
        tertiary: discordFuchsia,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: discordBlurple,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: discordBlurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: discordBlurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: discordBlurple.withOpacity(0.1),
        labelStyle: TextStyle(
          color: discordBlurple,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: discordBlurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Whitney',
      brightness: Brightness.dark,
      primaryColor: discordBlurple,
      scaffoldBackgroundColor: discordBlack,
      colorScheme: ColorScheme.fromSeed(
        seedColor: discordBlurple,
        brightness: Brightness.dark,
        primary: discordBlurple,
        secondary: discordGreen,
        tertiary: discordFuchsia,
        surface: discordDarkGrey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: discordDarkGrey,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black54,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: discordDarkGrey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: discordBlurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: discordBlurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: discordBlurple.withOpacity(0.2),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: discordBlurple, width: 2),
        ),
        filled: true,
        fillColor: discordDarkGrey,
      ),
    );
  }
}
