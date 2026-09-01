import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_viewport_scope.dart';

/// Browser or phone frame for website-style showcases, driven by [DemoViewportScope].
class DemoWebsiteFrame extends StatelessWidget {
  const DemoWebsiteFrame({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mobile = DemoViewportScope.isMobileView(context);
    return DemoDeviceFrame(
      type: mobile ? DemoFrameType.phone : DemoFrameType.browser,
      title: title,
      child: child,
    );
  }
}
