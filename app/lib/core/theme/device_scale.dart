import 'package:flutter/widgets.dart';

enum DeviceSize { compact, medium, expanded }

class DeviceScale {
  DeviceScale._();

  static DeviceSize sizeClass(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    if (shortest < 380) return DeviceSize.compact;
    if (shortest < 600) return DeviceSize.medium;
    return DeviceSize.expanded;
  }

  static double factor(BuildContext context) {
    return switch (sizeClass(context)) {
      DeviceSize.compact => 0.92,
      DeviceSize.medium => 1.0,
      DeviceSize.expanded => 1.1,
    };
  }
}
