import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Coffee Palette
  static const Color primary = Color(0xFF6F4E37); // Rich Coffee Brown
  static const Color primaryDark = Color(0xFF3D271D); // Espresso Dark
  static const Color primaryLight = Color(0xFF8D6E63); // Warm Mocha
  static const Color secondary = Color(0xFFD4A373); // Caramel / Amber
  static const Color accent = Color(0xFFE9C46A); // Warm Honey

  // Background & Surfaces - Light
  static const Color backgroundLight = Color(0xFFFBF8F5); // Cream Latte
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;

  // Background & Surfaces - Dark
  static const Color backgroundDark = Color(0xFF1A1614);
  static const Color surfaceDark = Color(0xFF26211E);
  static const Color cardDark = Color(0xFF2E2824);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF2B2118);
  static const Color textSecondaryLight = Color(0xFF756F6B);
  static const Color textPrimaryDark = Color(0xFFF5EFEB);
  static const Color textSecondaryDark = Color(0xFFA89F9A);

  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral & Borders
  static const Color borderLight = Color(0xFFE6DED8);
  static const Color borderDark = Color(0xFF4A403A);
  static const Color inputFillLight = Color(0xFFF5EFEB);
  static const Color inputFillDark = Color(0xFF332B26);
  static const Color dividerLight = Color(0xFFEFE8E2);
  static const Color dividerDark = Color(0xFF3A322C);
}
