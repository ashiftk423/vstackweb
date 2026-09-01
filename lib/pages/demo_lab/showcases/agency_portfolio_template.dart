import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class AgencyPortfolioTemplate extends StatefulWidget {
  const AgencyPortfolioTemplate({super.key});

  @override
  State<AgencyPortfolioTemplate> createState() => _AgencyPortfolioTemplateState();
}

class _AgencyPortfolioTemplateState extends State<AgencyPortfolioTemplate> {
  String _filter = 'All';
  static const _projects = [
    ('Brand Refresh', 'Branding', Color(0xFF5B8CFF)),
    ('E-commerce Launch', 'Web', Color(0xFF7C5CFF)),
    ('Mobile Banking', 'App', Color(0xFF2DD4BF)),
    ('Campaign Site', 'Marketing', Color(0xFFF59E0B)),
    ('SaaS Dashboard', 'Product', Color(0xFFEC4899)),
    ('3D Product Config', '3D', Color(0xFF6366F1)),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? _projects
        : _projects.where((p) => p.$2 == _filter).toList();

    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'portfolio',
      child: DemoTemplateScaffold(
        brand: 'Studio V',
        navItems: const ['Work', 'Services', 'About', 'Contact'],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selected Work', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['All', 'Branding', 'Web', 'App', '3D'].map((f) {
                  final selected = _filter == f;
                  return FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: filtered.map((p) => _ProjectCard(title: p.$1, tag: p.$2, color: p.$3)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.title, required this.tag, required this.color});

  final String title;
  final String tag;
  final Color color;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 220,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color.withValues(alpha: 0.35), VStackColors.surface],
              begin: Alignment.topLeft,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VStackColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.tag.toUpperCase(), style: TextStyle(color: widget.color, fontSize: 10, letterSpacing: 1)),
              const Spacer(),
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
