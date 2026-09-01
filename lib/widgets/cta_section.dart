import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class CtaBanner extends StatelessWidget {
  const CtaBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.route = '/start-project',
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final String route;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PageSection(
      child: ScrollReveal(
        id: 'cta-$title',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(VStackSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VStackRadius.xl),
            gradient: LinearGradient(
              colors: [
                VStackColors.surface,
                VStackColors.accent.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(color: VStackColors.accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: VStackSpacing.sm),
              Text(subtitle, style: const TextStyle(color: VStackColors.muted, height: 1.5)),
              const SizedBox(height: VStackSpacing.lg),
              FilledButton(
                onPressed: onPressed ?? () => context.go(route),
                style: FilledButton.styleFrom(
                  backgroundColor: VStackColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqSection extends StatelessWidget {
  const FaqSection({super.key, required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FAQ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: VStackSpacing.lg),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: VStackSpacing.sm),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: VStackSpacing.md),
                      child: Text(item.$2, style: const TextStyle(color: VStackColors.muted, height: 1.5)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      itemCount: features.length,
      desktopColumns: 3,
      tabletColumns: 2,
      itemBuilder: (context, i) {
        return VStackCard(
          padding: const EdgeInsets.all(VStackSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: VStackColors.accent, size: 20),
              const SizedBox(width: VStackSpacing.sm),
              Expanded(
                child: Text(features[i], style: const TextStyle(fontSize: 14, height: 1.4)),
              ),
            ],
          ),
        );
      },
    );
  }
}
