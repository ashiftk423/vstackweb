import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

/// Compact back navigation for detail / nested pages.
class PageBackLink extends StatelessWidget {
  const PageBackLink({
    super.key,
    required this.label,
    required this.route,
  });

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return PageSection(
      top: VStackSpacing.lg,
      bottom: 0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => context.go(route),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: VStackColors.muted,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
        ),
      ),
    );
  }
}
