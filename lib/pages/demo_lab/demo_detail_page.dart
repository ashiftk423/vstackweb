import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/pages/demo_lab/demo_registry.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_showcase_shell.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class DemoDetailPage extends StatelessWidget {
  const DemoDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final demo = SiteContentScope.of(context).demoBySlug(slug);
    if (demo == null) {
      return const Center(child: Text('Demo not found', style: TextStyle(color: VStackColors.muted)));
    }

    return DemoShowcaseShell(
      demo: demo,
      preview: buildDemoPreviewLoader(demo),
    );
  }
}
