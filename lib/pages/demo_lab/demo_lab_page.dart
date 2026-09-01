import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/models/demo.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/demo_card.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class DemoLabPage extends StatefulWidget {
  const DemoLabPage({super.key});

  @override
  State<DemoLabPage> createState() => _DemoLabPageState();
}

class _DemoLabPageState extends State<DemoLabPage> {
  String _category = 'all';

  List<DemoEntry> _filtered(List<DemoEntry> demos) {
    if (_category == 'all') return demos;
    return demos.where((d) => d.showcaseCategory == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final demos = _filtered(content.demos);

    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Demo Lab',
            title: 'See what we can build',
            subtitle: 'Templates, motion design, architecture, and 3D — interactive showcases of VSTACK craft.',
          ),
          PageSection(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _CapabilityPill(icon: Icons.palette_outlined, label: 'UI Craft'),
                _CapabilityPill(icon: Icons.animation_outlined, label: 'Motion Design'),
                _CapabilityPill(icon: Icons.architecture_outlined, label: 'Architecture'),
                _CapabilityPill(icon: Icons.view_in_ar_outlined, label: '3D & Games'),
              ],
            ),
          ),
          PageSection(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DemoEntry.showcaseCategories.map((c) {
                  final selected = _category == c.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.$2),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = c.$1),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          PageSection(
            child: demos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No showcases in this category yet.', style: TextStyle(color: VStackColors.muted)),
                  )
                : ResponsiveGrid(
                    itemCount: demos.length,
                    desktopColumns: 3,
                    itemBuilder: (_, i) => DemoCard(demo: demos[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityPill extends StatelessWidget {
  const _CapabilityPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: VStackColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VStackColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: VStackColors.accent),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
