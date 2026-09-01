import 'package:flutter/material.dart';

enum DemoViewportMode { desktop, mobile }

class DemoViewportScope extends InheritedWidget {
  const DemoViewportScope({
    super.key,
    required this.mode,
    required super.child,
  });

  final DemoViewportMode mode;

  bool get isMobile => mode == DemoViewportMode.mobile;

  static DemoViewportScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DemoViewportScope>();
  }

  static bool isMobileView(BuildContext context) {
    return maybeOf(context)?.isMobile ?? false;
  }

  @override
  bool updateShouldNotify(DemoViewportScope oldWidget) => mode != oldWidget.mode;
}
