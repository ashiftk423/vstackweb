import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/models/solution.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class SolutionCard extends StatefulWidget {
  const SolutionCard({
    super.key,
    required this.solution,
    this.compact = false,
  });

  final Solution solution;
  final bool compact;

  @override
  State<SolutionCard> createState() => _SolutionCardState();
}

class _SolutionCardState extends State<SolutionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.solution;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        child: VStackCard(
          highlight: _hovered,
          onTap: () => context.go('/solutions/${s.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SolutionIcon(name: s.icon, size: 28),
              const SizedBox(height: VStackSpacing.md),
              Text(
                s.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: VStackSpacing.xs),
              Text(
                s.homeCardDescription.isNotEmpty ? s.homeCardDescription : s.shortDescription,
                style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: VStackSpacing.lg),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: _hovered ? VStackColors.accent : VStackColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: _hovered ? VStackColors.accent : VStackColors.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SolutionIcon extends StatelessWidget {
  const SolutionIcon({super.key, required this.name, this.size = 24});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        color: VStackColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VStackRadius.sm),
      ),
      child: Icon(resolveSolutionIcon(name), color: VStackColors.accent, size: size),
    );
  }
}

IconData resolveSolutionIcon(String name) {
  return switch (name) {
    'code' => Icons.code_outlined,
    'campaign' => Icons.campaign_outlined,
    'computer' => Icons.computer_outlined,
    'videocam' => Icons.videocam_outlined,
    'language' => Icons.language_outlined,
    'phone_android' => Icons.phone_android_outlined,
    'local_shipping' => Icons.local_shipping_outlined,
    _ => Icons.build_outlined,
  };
}
