import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/models/work_project.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final WorkProject project;

  @override
  Widget build(BuildContext context) {
    return VStackCard(
      onTap: () => context.go('/work/${project.slug}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.primaryImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(VStackRadius.lg)),
              child: Image.asset(
                project.primaryImage!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(VStackSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.category.toUpperCase(),
                  style: const TextStyle(color: VStackColors.accent, fontSize: 10, letterSpacing: 1.2),
                ),
                const SizedBox(height: 6),
                Text(project.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: VStackSpacing.sm),
                Text(
                  project.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: VStackSpacing.md),
                Text(project.tech, style: const TextStyle(color: VStackColors.accent2, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
