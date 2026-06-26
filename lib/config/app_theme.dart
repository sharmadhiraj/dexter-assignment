import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const teal = Color(0xFF009688);
  static const tealLight = Color(0xFFE0F2F1);
  static const tealMuted = Color(0xFF80CBC4);
  static const iconDisabled = Color(0xFFD1D5DB);
}

ThemeData buildAppTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
      primaryColor: AppColors.teal,
      useMaterial3: true,
    );
