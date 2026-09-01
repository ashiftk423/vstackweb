import 'package:flutter/material.dart';
import 'package:vstackweb/layouts/app_shell.dart';

/// Scrollable page body with footer at the end (not pinned to viewport).
class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          const VStackFooter(),
        ],
      ),
    );
  }
}
