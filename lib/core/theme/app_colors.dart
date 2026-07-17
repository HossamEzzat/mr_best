import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF4F46E5); // Rich Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Attendance status colors
  static const Color present = Color(0xFF059669); // Emerald 600
  static const Color absent = Color(0xFFE11D48); // Rose 600
  static const Color late = Color(0xFFD97706); // Amber 600
  static const Color tealOffset = Color(0xFFF0FDF4); // Light emerald bg

  // Theme colors (Light)
  static const Color bgLight = Color(0xFFF8FAFC); // Very light slate
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Very dark slate
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color cardShadowLight = Color(0x0C000000);

  // Theme colors (Dark)
  static const Color bgDark = Color(0xFF0B0F19); // Ultra dark sleek slate
  static const Color surfaceDark = Color(0xFF151C2C); // Slightly lighter slate surface
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color cardShadowDark = Color(0x26000000);

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
