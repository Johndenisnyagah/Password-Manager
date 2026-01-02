import 'package:flutter/material.dart';

/// Defines the application's color palette.
///
/// Includes colors for the modern purple theme, backgrounds, text, and gradients.
class AppColors {
  // Modern Purple Theme (matching UI concept)
  static const Color deepPurple = Color(0xFF4C3BCF);
  static const Color mediumPurple = Color(0xFF5B4FC9);
  static const Color lightPurple = Color(0xFF7C6FD9);
  static const Color palePurple = Color(0xFFE8E5FF);
  
  // Backgrounds
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color darkText = Color(0xFF2D2D2D);
  static const Color mediumText = Color(0xFF6B6B6B);
  static const Color lightText = Color(0xFF9B9B9B);
  
  // Gradients
  static const Gradient purpleGradient = LinearGradient(
    colors: [deepPurple, mediumPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient backgroundGradient = LinearGradient(
    colors: [lightBackground, Color(0xFFEEEEF0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2C2C2C);
}

/// Defines the application's light and dark themes.
class AppTheme {
  /// Returns the light mode [ThemeData].
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepPurple,
        secondary: AppColors.mediumPurple,
        surface: AppColors.cardBackground,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.mediumText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.lightText,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.lightText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepPurple, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.mediumText,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.lightText,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  /// Returns the dark mode [ThemeData].
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.lightPurple,
        secondary: AppColors.mediumPurple,
        surface: AppColors.darkCardBackground,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFB0B0B0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF909090),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Color(0xFF808080),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252525),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightPurple, width: 2),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF909090),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF707070),
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
