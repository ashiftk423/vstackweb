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
            child: Center(
              child: Icon(_demoIcon(demo.interactiveType), size: 40, color: VStackColors.accent),
            ),
          ),
          const SizedBox(height: VStackSpacing.md),
          Text(
            demo.category.toUpperCase(),
            style: const TextStyle(color: VStackColors.accent2, fontSize: 10, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(demo.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: VStackSpacing.xs),
          Text(
            demo.description,
            style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: VStackSpacing.md),
          const Row(
            children: [
              Text('Explore Demo', style: TextStyle(color: VStackColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: VStackColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  IconData _demoIcon(String type) {
    return switch (type) {
      'erp' => Icons.dashboard_outlined,
      'crm' => Icons.people_outline,
      'pos' => Icons.point_of_sale_outlined,
      'website' => Icons.language_outlined,
      'ecommerce' => Icons.shopping_bag_outlined,
      'mobile' => Icons.phone_android_outlined,
      '3d' => Icons.view_in_ar_outlined,
      'management' => Icons.business_center_outlined,
      _ => Icons.play_circle_outline,
    };
  }
}
