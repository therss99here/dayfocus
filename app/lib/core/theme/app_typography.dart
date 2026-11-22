import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'device_scale.dart';

class AppTypography {
  AppTypography._();

  static Color _primary(Brightness b) =>
      b == Brightness.dark ? AppColors.textPrimary : AppColors.textPrimaryLight;

  static Color _secondary(Brightness b) =>
      b == Brightness.dark
          ? AppColors.textSecondary
          : AppColors.textSecondaryLight;

  // ── Material TextTheme (for default widget styles) ─────────────────────────

  static TextTheme textTheme(Brightness brightness) {
    final primary = _primary(brightness);
    return TextTheme(
      displaySmall: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _secondary(brightness),
        letterSpacing: 1.5,
      ),
      bodyLarge: GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      labelMedium: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      bodySmall: GoogleFonts.sora(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        letterSpacing: 0.1,
      ),
    );
  }

  // ── Named role styles (primary API for widget code) ────────────────────────

  static TextStyle display(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 22 * s,
      fontWeight: FontWeight.w700,
      color: _primary(b),
      letterSpacing: -0.3,
    );
  }

  static TextStyle sectionLabel(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 12 * s,
      fontWeight: FontWeight.w700,
      color: _secondary(b),
      letterSpacing: 1.5,
    );
  }

  static TextStyle appTitle(BuildContext context) {
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 17 * s,
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
      letterSpacing: -0.3,
    );
  }

  static TextStyle body(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 16 * s,
      fontWeight: FontWeight.w400,
      color: _primary(b),
    );
  }

  static TextStyle bodyEmphasis(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 16 * s,
      fontWeight: FontWeight.w600,
      color: _primary(b),
      letterSpacing: -0.1,
    );
  }

  static TextStyle bodySecondary(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 15 * s,
      fontWeight: FontWeight.w400,
      color: _primary(b),
    );
  }

  static TextStyle input(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 15 * s,
      fontWeight: FontWeight.w400,
      color: _primary(b),
    );
  }

  static TextStyle label(BuildContext context) {
    final b = Theme.of(context).brightness;
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 12 * s,
      fontWeight: FontWeight.w600,
      color: _primary(b),
    );
  }

  static TextStyle time(BuildContext context) {
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 13 * s,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      letterSpacing: 0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle timeFaded(BuildContext context) {
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 11 * s,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted.withValues(alpha: 0.35),
      letterSpacing: 0.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle caption(BuildContext context) {
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 11 * s,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      letterSpacing: 0.1,
    );
  }

  static TextStyle micro(BuildContext context) {
    final s = DeviceScale.factor(context);
    return GoogleFonts.sora(
      fontSize: 10 * s,
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
      letterSpacing: 0.8,
    );
  }
}
