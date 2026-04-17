import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE60A15);
  static const Color backgroundDark = Color(0xFF221011);
  static const Color backgroundLight = Color(0xFFF8F5F6);

  static const Color textDark = Color(0xFF0F172A); // slate-900
  static const Color textLight = Color(0xFFF1F5F9); // slate-100
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color textSecondary = Color(0xFF64748B); // slate-500

  static const Color inputBackground = Color(0xFFF1F5F9); // slate-100
  static Color inputBackgroundDark = primary.withValues(alpha: 0.05);
  static const Color borderLight = Color(0xFFE2E8F0); // slate-200
  static Color borderDark = primary.withValues(alpha: 0.1);

  static const Color surfaceDark = Color(0xFF2A1415);
  static const Color borderDarkSolid = Color(0xFF3D1D1F);

  static const Color accentText = Color(0xFFBA9C9D);
  static const Color neutralMuted = Color(0xFF392829);
}
