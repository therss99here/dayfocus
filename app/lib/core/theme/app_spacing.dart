import 'package:flutter/widgets.dart';

import 'device_scale.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;

  static const double radiusSm = 6;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  // Timeline
  static const double slotHeight = 56;
  static const double timelineLabelWidth = 52;
  static const double leftPanelWidth = 240;

  static double scaled(double value, BuildContext context) =>
      value * DeviceScale.factor(context);

  static double slotHeightScaled(BuildContext context) =>
      slotHeight * DeviceScale.factor(context);

  static double timelineLabelWidthScaled(BuildContext context) =>
      timelineLabelWidth * DeviceScale.factor(context);

  static double leftPanelWidthScaled(BuildContext context) =>
      leftPanelWidth * DeviceScale.factor(context);
}
