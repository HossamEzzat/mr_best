import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFFEC4899); // Pink/Rose
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Attendance status colors
  static const Color present = Color(0xFF0D9488); // Teal
  static const Color absent = Color(0xFFE11D48); // Rose
  static const Color late = Color(0xFFD97706); // Amber
  static const Color tealOffset = Color(0xFFE6F4F1);

  // Theme colors (Light)
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color cardShadowLight = Color(0x0F000000);

  // Theme colors (Dark)
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color cardShadowDark = Color(0x1F000000);

  // Categories of exams/tasks colors
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'الامتحان الشهري':
        return Colors.purple;
      case 'التقييم الأسبوعي':
        return Colors.blue;
      case 'اختبار الدرس':
        return Colors.teal;
      case 'الواجب':
        return Colors.orange;
      case 'امتحان نصف الترم':
        return Colors.red;
      case 'درجة المدرسة':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
