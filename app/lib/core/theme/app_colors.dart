import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // -- Dark surfaces
  static const bgDark = Color(0xFF0F0F12);
  static const surfaceDark = Color(0xFF1C1C20);
  static const surface2Dark = Color(0xFF252529);
  static const borderDark = Color(0xFF2E2E33);

  // -- Light surfaces
  static const bgLight = Color(0xFFF9F9FB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF2F2F5);
  static const borderLight = Color(0xFFE5E5EA);

  // -- Text (shared)
  static const textPrimary = Color(0xFFF5F5F7);
  static const textPrimaryLight = Color(0xFF1C1C1E);
  static const textMuted = Color(0xFF8E8E93);

  // -- Brand accent
  static const accent = Color(0xFFF5A023);
  static const accentDim = Color(0x33F5A023);

  // -- Time block states
  static const stateScheduled = Color(0xFF4A90D9);
  static const stateScheduledDim = Color(0x334A90D9);
  static const stateInProgress = Color(0xFFF5A023);   // = accent
  static const stateInProgressDim = Color(0x33F5A023);
  static const stateCompleted = Color(0xFF5E9E6F);
  static const stateCompletedDim = Color(0x335E9E6F);
  static const stateMissed = Color(0xFFE06C6C);
  static const stateMissedDim = Color(0x33E06C6C);
  static const stateUnscheduled = Color(0xFF8E8E93);
}
