import 'package:flutter/material.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

abstract final class VStackSpacing {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const section = 56.0;
}

abstract final class VStackRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.symmetric(horizontal: AppLayout.pagePadding(context));
    return Padding(
      padding: pad,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.desktopColumns = 3,
    this.tabletColumns = 2,
    this.spacing = VStackSpacing.md,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int desktopColumns;
  final int tabletColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final cols = AppLayout.gridColumns(
      context,
      desktop: desktopColumns,
      tablet: tabletColumns,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - (cols - 1) * spacing) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(itemCount, (i) {
            return SizedBox(
              width: cols == 1 ? constraints.maxWidth : w,
              child: itemBuilder(context, i),
            );
          }),
        );
      },
    );
  }
}

class VStackCard extends StatelessWidget {
  const VStackCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(VStackSpacing.lg),
    this.highlight = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: padding,
      decoration: BoxDecoration(
        color: VStackColors.surface,
        borderRadius: BorderRadius.circular(VStackRadius.lg),
        border: Border.all(
          color: highlight ? VStackColors.accent.withValues(alpha: 0.45) : VStackColors.border,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VStackRadius.lg),
        child: card,
      ),
    );
  }
}

class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.top = VStackSpacing.section,
    this.bottom = VStackSpacing.lg,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: ResponsiveContainer(child: child),
    );
  }
}
