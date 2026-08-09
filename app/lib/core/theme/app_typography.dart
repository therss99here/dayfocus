import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const _baseFamily = 'SF Pro Display';

  static TextTheme textTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColors.textPrimaryLight;

    return TextTheme(
      // Day header, empty state headings
      displaySmall: TextStyle(
        fontFamily: _baseFamily,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: primary,
        letterSpacing: -0.5,
      ),
      // Section headers: Priorities, Brain Dump
      titleLarge: TextStyle(
        fontFamily: _baseFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.3,
      ),
      // Task names, brain dump text
      bodyLarge: TextStyle(
        fontFamily: _baseFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      // Time slot labels (monospace feel via letterSpacing)
      labelMedium: TextStyle(
        fontFamily: 'Courier',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
      ),
      // Muted metadata
      bodySmall: TextStyle(
        fontFamily: _baseFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
    );
  }
}
