import 'package:flutter/material.dart';

class DemoTemplateScaffold extends StatelessWidget {
  const DemoTemplateScaffold({
    super.key,
    required this.body,
    this.header,
    this.theme,
    this.backgroundColor = const Color(0xFF0A1020),
  });

  final Widget body;
  final Widget? header;
  final ThemeData? theme;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        if (header != null) header!,
        Expanded(child: body),
      ],
    );

    return Container(
      color: backgroundColor,
      child: theme != null ? Theme(data: theme!, child: child) : child,
    );
  }
}
