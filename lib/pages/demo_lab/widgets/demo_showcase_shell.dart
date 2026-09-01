import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/models/demo.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class DemoShowcaseShell extends StatelessWidget {
  const DemoShowcaseShell({
    super.key,
    required this.demo,
    required this.preview,
  });

  final DemoEntry demo;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;

    final panel = _SidePanel(demo: demo);

    if (wide) {
      return Column(
        children: [
          _TopBar(demo: demo),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 65, child: preview),
                SizedBox(width: 360, child: panel),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _TopBar(demo: demo),
        Expanded(
          flex: 3,
          child: preview,
        ),
        Flexible(
          flex: 2,
          child: SingleChildScrollView(child: panel),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.demo});

  final DemoEntry demo;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    'VSTACK Showcase — Sample Template',
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
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.demo});

  final DemoEntry demo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VStackColors.bg,
      padding: const EdgeInsets.all(VStackSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            demo.category.toUpperCase(),
            style: const TextStyle(color: VStackColors.accent2, fontSize: 10, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(demo.description, style: const TextStyle(color: VStackColors.muted, height: 1.5)),
          if (demo.skills.isNotEmpty) ...[
            const SizedBox(height: VStackSpacing.lg),
            const Text('Skills demonstrated', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: demo.skills
                  .map(
                    (s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 11)),
                      backgroundColor: VStackColors.surface,
                      side: const BorderSide(color: VStackColors.border),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (demo.highlights.isNotEmpty) ...[
            const SizedBox(height: VStackSpacing.lg),
            const Text('Why this matters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            ...demo.highlights.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: VStackColors.accent.withValues(alpha: 0.9)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(h, style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.4))),
                  ],
                ),
              ),
            ),
          ],
          if (demo.architectureNote != null) ...[
            const SizedBox(height: VStackSpacing.lg),
            VStackCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.architecture_outlined, size: 16, color: VStackColors.accent),
                      SizedBox(width: 8),
                      Text('Architecture', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    demo.architectureNote!,
                    style: const TextStyle(color: VStackColors.muted, fontSize: 12, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
