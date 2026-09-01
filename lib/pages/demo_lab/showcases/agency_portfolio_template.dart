import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
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

    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'portfolio',
      child: DemoTemplateScaffold(
        theme: DemoThemes.saas(),
        backgroundColor: Colors.white,
        header: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              const Text('Studio V', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const Spacer(),
              const Text('Work', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 24),
              Text('About', style: TextStyle(color: Colors.grey.shade600)),
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
              const Text('Selected Work', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
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
                        child: Text(widget.project.category.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
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
