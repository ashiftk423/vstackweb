import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/models/demo.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.demo});

  final DemoEntry demo;

  @override
  Widget build(BuildContext context) {
    return VStackCard(
      onTap: () => context.go('/demo-lab/${demo.slug}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VStackRadius.md),
              gradient: LinearGradient(
                colors: [
                  VStackColors.surfaceLight,
                  VStackColors.accent.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: VStackColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: demo.previewImage != null
                ? Image.asset(demo.previewImage!, fit: BoxFit.cover, width: double.infinity)
                : Center(
                    child: Icon(_demoIcon(demo.interactiveType), size: 40, color: VStackColors.accent),
                  ),
          ),
          const SizedBox(height: VStackSpacing.md),
          Text(
            _categoryLabel(demo.showcaseCategory).toUpperCase(),
            style: const TextStyle(color: VStackColors.accent2, fontSize: 10, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(demo.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: VStackSpacing.xs),
          Text(
            demo.description,
            style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (demo.skills.isNotEmpty) ...[
            const SizedBox(height: VStackSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: demo.skills.take(3).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: VStackColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: VStackColors.border),
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 10, color: VStackColors.muted)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: VStackSpacing.md),
          const Row(
            children: [
              Text('Explore Showcase', style: TextStyle(color: VStackColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: VStackColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) => switch (cat) {
        'website' => 'Website',
        'desktop' => 'Desktop App',
        'mobile' => 'Mobile App',
        'motion' => 'Motion & UI',
        '3d' => '3D & Games',
        _ => demo.category,
      };

  IconData _demoIcon(String type) {
    return switch (type) {
      'website-saas' || 'website-agency' || 'website-ecommerce' => Icons.language_outlined,
      'desktop-admin' || 'desktop-pos' => Icons.desktop_windows_outlined,
      'mobile-fintech' || 'mobile-delivery' => Icons.phone_android_outlined,
      'motion-micro' || 'motion-scroll' => Icons.animation_outlined,
      '3d-character' || '3d-asset' => Icons.view_in_ar_outlined,
      _ => Icons.play_circle_outline,
    };
  }
}
