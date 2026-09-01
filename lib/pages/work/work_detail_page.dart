import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/models/work_project.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/cta_section.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class WorkDetailPage extends StatelessWidget {
  const WorkDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final project = content.workBySlug(slug);
    if (project == null) {
      return const Center(child: Text('Project not found'));
    }

    return PageScroll(
      child: Column(
        children: [
          PageHero(
            compact: true,
            badge: project.category,
            title: project.title,
            subtitle: project.description,
          ),
          if (project.primaryImage != null)
            PageSection(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VStackRadius.lg),
                child: Image.asset(project.primaryImage!, fit: BoxFit.cover),
              ),
            ),
          PageSection(child: _TextBlock(title: 'The challenge', body: project.challenge)),
          PageSection(top: VStackSpacing.lg, child: _TextBlock(title: 'The solution', body: project.solution)),
          PageSection(
            top: VStackSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What VSTACK built', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: VStackSpacing.lg),
                FeatureGrid(features: project.features),
                const SizedBox(height: VStackSpacing.lg),
                Text('Technology: ${project.tech}', style: const TextStyle(color: VStackColors.accent2)),
              ],
            ),
          ),
          CtaBanner(
            title: 'Need something similar?',
            subtitle: 'We can build a custom solution for your business.',
            buttonLabel: 'Start a Project',
            route: '/start-project',
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: VStackSpacing.md),
        Text(body, style: const TextStyle(color: VStackColors.muted, fontSize: 16, height: 1.6)),
      ],
    );
  }
}
