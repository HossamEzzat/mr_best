import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo', // Global modern font
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.light,
        background: AppColors.bgLight,
        surface: AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0, // Flat design with border or soft shadow is more modern
        shadowColor: AppColors.cardShadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFF1F5F9), width: 1.5), // Subtle border
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo', // Global modern font
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.dark,
        background: AppColors.bgDark,
        surface: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shadowColor: AppColors.cardShadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark, // Seamless app bar in dark mode
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
