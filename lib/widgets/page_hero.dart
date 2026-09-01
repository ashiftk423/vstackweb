import 'package:flutter/material.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.primaryLabel,
    this.primaryRoute,
    this.onPrimary,
    this.secondaryLabel,
    this.secondaryRoute,
    this.onSecondary,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final String? primaryLabel;
  final String? primaryRoute;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final String? secondaryRoute;
  final VoidCallback? onSecondary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mobile = AppLayout.isMobile(context);
    return PageSection(
      top: compact ? VStackSpacing.xl : VStackSpacing.section + 8,
      child: ScrollReveal(
        id: 'hero-$title',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null) ...[
              Text(
                badge!.toUpperCase(),
                style: const TextStyle(
                  color: VStackColors.accent,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: VStackSpacing.sm),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: compact
                    ? (mobile ? 28 : 36)
                    : AppLayout.heroTitleSize(context),
                fontWeight: FontWeight.w800,
                height: 1.08,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: VStackSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: VStackColors.muted,
                  fontSize: mobile ? 15 : 18,
                  height: 1.55,
                ),
              ),
            ),
            if (primaryLabel != null || secondaryLabel != null) ...[
              const SizedBox(height: VStackSpacing.xl),
              Wrap(
                spacing: VStackSpacing.sm,
                runSpacing: VStackSpacing.sm,
                children: [
                  if (primaryLabel != null)
                    FilledButton(
                      onPressed: onPrimary,
                      style: FilledButton.styleFrom(
                        backgroundColor: VStackColors.accent,
                        padding: EdgeInsets.symmetric(
                          horizontal: mobile ? 20 : 28,
                          vertical: 16,
                        ),
                      ),
                      child: Text(primaryLabel!),
                    ),
                  if (secondaryLabel != null)
                    OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VStackColors.text,
                        side: const BorderSide(color: VStackColors.border),
                        padding: EdgeInsets.symmetric(
                          horizontal: mobile ? 20 : 28,
                          vertical: 16,
                        ),
                      ),
                      child: Text(secondaryLabel!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
