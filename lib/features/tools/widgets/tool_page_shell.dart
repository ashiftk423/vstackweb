import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/features/tools/models/tool_definition.dart';
import 'package:vstackweb/features/tools/services/tool_seo.dart';
import 'package:vstackweb/features/tools/widgets/tool_card.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class ToolPageShell extends StatefulWidget {
  const ToolPageShell({
    super.key,
    required this.tool,
    required this.child,
  });

  final ToolDefinition tool;
  final Widget child;

  @override
  State<ToolPageShell> createState() => _ToolPageShellState();
}

class _ToolPageShellState extends State<ToolPageShell> {
  final _seo = createToolSeoService();

  @override
  void initState() {
    super.initState();
    _seo.apply(widget.tool);
  }

  @override
  void didUpdateWidget(covariant ToolPageShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tool.id != widget.tool.id) {
      _seo.apply(widget.tool);
    }
  }

  @override
  void dispose() {
    _seo.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    return PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHero(
            compact: true,
            badge: 'Tools',
            title: tool.seo.h1,
            subtitle: tool.description,
          ),
          PageSection(
            top: VStackSpacing.lg,
            child: widget.child,
          ),
          if (tool.howItWorks.isNotEmpty)
            PageSection(
              child: VStackCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How it works', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: VStackSpacing.md),
                    ...tool.howItWorks.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${e.key + 1}. ', style: const TextStyle(color: VStackColors.accent)),
                                Expanded(child: Text(e.value, style: const TextStyle(height: 1.45))),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          if (tool.seo.faq.isNotEmpty)
            PageSection(
              child: ToolFAQ(faq: tool.seo.faq),
            ),
          PageSection(
            child: RelatedTools(tool: tool),
          ),
          if (tool.contextCtaLabel != null && tool.contextCtaRoute != null)
            PageSection(
              child: ToolContextCta(
                label: tool.contextCtaLabel!,
                route: tool.contextCtaRoute!,
              ),
            ),
          PageSection(
            bottom: VStackSpacing.xl,
            child: Center(
              child: TextButton(
                onPressed: () => context.go('/tools'),
                child: const Text('← Back to all Tools'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolFAQ extends StatelessWidget {
  const ToolFAQ({super.key, required this.faq});

  final List<(String, String)> faq;

  @override
  Widget build(BuildContext context) {
    return VStackCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FAQ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: VStackSpacing.sm),
          ...faq.map(
            (item) => ExpansionTile(
              title: Text(item.$1, style: const TextStyle(fontSize: 14)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(item.$2, style: const TextStyle(color: VStackColors.muted, height: 1.45)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ToolContextCta extends StatelessWidget {
  const ToolContextCta({super.key, required this.label, required this.route});

  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return VStackCard(
      highlight: true,
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          FilledButton(onPressed: () => context.go(route), child: const Text('Learn more')),
        ],
      ),
    );
  }
}
