import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/pages/demo_lab/demos/crm_demo.dart';
import 'package:vstackweb/pages/demo_lab/demos/erp_demo.dart';
import 'package:vstackweb/pages/demo_lab/demos/pos_demo.dart';
import 'package:vstackweb/pages/demo_lab/demos/website_demo.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class DemoDetailPage extends StatelessWidget {
  const DemoDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final demo = SiteContentScope.of(context).demoBySlug(slug);
    if (demo == null) {
      return const Center(child: Text('Demo not found'));
    }

    return Column(
      children: [
        Material(
          color: VStackColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(onPressed: () => context.go('/demo-lab'), icon: const Icon(Icons.arrow_back)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(demo.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        'Interactive Demo — Sample Data',
                        style: TextStyle(color: VStackColors.accent.withValues(alpha: 0.9), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => context.go('/start-project?demo=${demo.slug}'),
                  child: const Text('Build Like This'),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _DemoBody(type: demo.interactiveType)),
      ],
    );
  }
}

class _DemoBody extends StatelessWidget {
  const _DemoBody({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      'erp' => const ErpDemo(),
      'crm' => const CrmDemo(),
      'pos' => const PosDemo(),
      'website' => const WebsiteDemo(),
      'ecommerce' => const EcommerceDemo(),
      'mobile' => const MobileDemo(),
      '3d' => const WebsiteDemo(title: '3D Website Preview'),
      'management' => const ErpDemo(compact: true),
      _ => const Center(child: Text('Demo preview coming soon')),
    };
  }
}
