import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';

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

    if (theme == null) {
      return Container(color: backgroundColor, child: child);
    }

    final bodyStyle = theme!.textTheme.bodyMedium ??
        const TextStyle(color: DemoThemes.inkSecondary, fontSize: 14, height: 1.4);

    return Container(
      color: backgroundColor,
      child: Theme(
        data: theme!,
        child: DefaultTextStyle(
          style: bodyStyle,
          child: IconTheme(
            data: IconThemeData(color: theme!.colorScheme.primary),
            child: child,
          ),
        ),
      ),
    );
  }
}
