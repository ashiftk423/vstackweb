import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/models/tool_definition.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({super.key, required this.tool});

  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    return VStackCard(
      onTap: tool.isActive ? () => context.go(tool.route) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tool.icon, color: VStackColors.accent, size: 22),
              const Spacer(),
              if (tool.isFree && tool.status == ToolStatus.active)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: VStackColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Free', style: TextStyle(fontSize: 10, color: VStackColors.accent)),
                ),
              if (tool.status == ToolStatus.comingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Soon', style: TextStyle(fontSize: 10, color: Colors.white54)),
                ),
            ],
          ),
          const SizedBox(height: VStackSpacing.sm),
          Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            tool.shortDescription,
            style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: VStackSpacing.sm),
          Row(
            children: [
              Text(tool.categoryLabel, style: TextStyle(color: VStackColors.muted.withValues(alpha: 0.8), fontSize: 11)),
              const Spacer(),
              const Text('Open Tool →', style: TextStyle(color: VStackColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class RelatedTools extends StatelessWidget {
  const RelatedTools({super.key, required this.tool});

  final ToolDefinition tool;

  @override
  Widget build(BuildContext context) {
    final related = tool.relatedToolIds
        .map(ToolsRegistry.byId)
        .whereType<ToolDefinition>()
        .toList();
    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Related Tools', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: VStackSpacing.md),
        ResponsiveGrid(
          itemCount: related.length,
          desktopColumns: 3,
          tabletColumns: 2,
          itemBuilder: (_, i) => ToolCard(tool: related[i]),
        ),
      ],
    );
  }
}
