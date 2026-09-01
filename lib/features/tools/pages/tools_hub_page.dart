import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/models/tool_definition.dart';
import 'package:vstackweb/features/tools/widgets/tool_card.dart';
import 'package:vstackweb/features/tools/widgets/tool_search_bar.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/section_header.dart';

class ToolsHubPage extends StatefulWidget {
  const ToolsHubPage({super.key});

  @override
  State<ToolsHubPage> createState() => _ToolsHubPageState();
}

class _ToolsHubPageState extends State<ToolsHubPage> {
  final _search = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ToolDefinition> get _filtered {
    var list = ToolsRegistry.search(_search.text);
    if (_category != null) {
      list = list.where((t) => t.categoryLabel == _category).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final popular = ToolsRegistry.popular;
    final filtered = _filtered;

    return PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHero(
            compact: true,
            badge: 'Tools',
            title: 'Tools',
            subtitle: 'Useful tools built to make everyday work simpler.',
          ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ToolSearchBar(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: VStackSpacing.md),
                ToolCategoryChips(
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
              ],
            ),
          ),
          if (_search.text.isEmpty && _category == null) ...[
            PageSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    id: 'popular-tools',
                    tag: 'POPULAR',
                    title: 'Popular tools',
                    subtitle: 'Frequently used utilities.',
                  ),
                  const SizedBox(height: VStackSpacing.lg),
                  ResponsiveGrid(
                    itemCount: popular.length,
                    itemBuilder: (_, i) => ToolCard(tool: popular[i]),
                  ),
                ],
              ),
            ),
          ],
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  id: 'all-tools',
                  tag: 'ALL TOOLS',
                  title: _search.text.isEmpty && _category == null ? 'All tools' : 'Results',
                  subtitle: '${filtered.length} tool${filtered.length == 1 ? '' : 's'} available',
                ),
                const SizedBox(height: VStackSpacing.lg),
                if (filtered.isEmpty)
                  const Text('No tools match your search.', style: TextStyle(color: VStackColors.muted))
                else
                  ResponsiveGrid(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ToolCard(tool: filtered[i]),
                  ),
              ],
            ),
          ),
          PageSection(
            bottom: VStackSpacing.xl,
            child: Center(
              child: OutlinedButton(
                onPressed: () => context.go('/start-project'),
                child: const Text('Need a custom tool for your business? Talk to VSTACK'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
