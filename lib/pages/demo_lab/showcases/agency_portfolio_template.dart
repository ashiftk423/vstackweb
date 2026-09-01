import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_viewport_scope.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_website_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';

class AgencyPortfolioTemplate extends StatefulWidget {
  const AgencyPortfolioTemplate({super.key});

  @override
  State<AgencyPortfolioTemplate> createState() => _AgencyPortfolioTemplateState();
}

class _AgencyPortfolioTemplateState extends State<AgencyPortfolioTemplate> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final projects = _filter == 'All'
        ? DemoSampleData.portfolio
        : DemoSampleData.portfolio.where((p) => p.category == _filter).toList();

    return DemoWebsiteFrame(
      title: 'portfolio',
      child: DemoTemplateScaffold(
        theme: DemoThemes.saas(),
        backgroundColor: Colors.white,
        header: DemoViewportScope.isMobileView(context)
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Text('Studio V', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: DemoThemes.ink)),
                    const Spacer(),
                    FilledButton(onPressed: () {}, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: const Text('Contact', style: TextStyle(fontSize: 12))),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    const Text('Studio V', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: DemoThemes.ink)),
                    const Spacer(),
                    const Text('Work', style: TextStyle(fontWeight: FontWeight.w600, color: DemoThemes.inkSecondary)),
                    const SizedBox(width: 24),
                    const Text('About', style: TextStyle(color: DemoThemes.inkMuted)),
                    const SizedBox(width: 24),
                    FilledButton(onPressed: () {}, child: const Text('Start a project')),
                  ],
                ),
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selected Work', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DemoThemes.ink)),
              const SizedBox(height: 4),
              Text('Branding, web, apps & 3D — crafted for growth.', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: ['All', 'Branding', 'Web', 'App', '3D', 'Marketing'].map((f) {
                  final sel = _filter == f;
                  return FilterChip(
                    label: Text(f),
                    selected: sel,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: DemoViewportScope.isMobileView(context) ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: DemoViewportScope.isMobileView(context) ? 1.6 : 1.4,
                ),
                itemCount: projects.length,
                itemBuilder: (_, i) => _ProjectTile(project: projects[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTile extends StatefulWidget {
  const _ProjectTile({required this.project});
  final DemoPortfolioProject project;

  @override
  State<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<_ProjectTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1,
        duration: const Duration(milliseconds: 250),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(widget.project.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: _hover ? Colors.black.withValues(alpha: 0.55) : Colors.black.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(4)),
                        child: Text(widget.project.category.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: DemoThemes.ink)),
                      ),
                      const Spacer(),
                      Text(widget.project.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
