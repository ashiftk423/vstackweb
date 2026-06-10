import 'package:flutter/material.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.id,
    required this.tag,
    required this.title,
    this.subtitle,
  });

  final String? id;
  final String tag;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final mobile = AppLayout.isMobile(context);

    return ScrollReveal(
      id: id ?? 'header-$tag',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: VStackColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.1,
                  fontSize: mobile ? 26 : null,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: TextStyle(
                color: VStackColors.muted,
                fontSize: mobile ? 14 : 16,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
