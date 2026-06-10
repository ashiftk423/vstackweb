import 'package:flutter/material.dart';

/// Shared breakpoints for mobile / tablet / desktop layouts.
abstract final class AppLayout {
  static const mobileMax = 600.0;
  static const tabletMax = 900.0;
  static const contactSplitMin = 1000.0;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) => width(context) < mobileMax;
  static bool isTablet(BuildContext context) =>
      width(context) >= mobileMax && width(context) < tabletMax;
  static bool isDesktop(BuildContext context) => width(context) >= tabletMax;

  static double pagePadding(BuildContext context) {
    final w = width(context);
    if (w < mobileMax) return 16;
    if (w < tabletMax) return 24;
    return 48;
  }

  static double heroTitleSize(BuildContext context) {
    final w = width(context);
    if (w < mobileMax) return 32;
    if (w < tabletMax) return 42;
    return 56;
  }

  static int gridColumns(BuildContext context, {int desktop = 4, int tablet = 2}) {
    final w = width(context);
    if (w < mobileMax) return 1;
    if (w < tabletMax) return tablet;
    return desktop;
  }
}
