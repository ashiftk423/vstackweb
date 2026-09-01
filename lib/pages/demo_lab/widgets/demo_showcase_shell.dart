import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/models/demo.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_viewport_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class DemoShowcaseShell extends StatefulWidget {
  const DemoShowcaseShell({
    super.key,
    required this.demo,
    required this.preview,
  });

  final DemoEntry demo;
  final Widget preview;

  @override
  State<DemoShowcaseShell> createState() => _DemoShowcaseShellState();
}

class _DemoShowcaseShellState extends State<DemoShowcaseShell> {
  DemoViewportMode _viewport = DemoViewportMode.desktop;

  bool get _supportsViewportToggle {
    return widget.demo.showcaseCategory == 'website' ||
        widget.demo.interactiveType == 'motion-scroll';
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final panel = _SidePanel(demo: widget.demo);

    final preview = ClipRect(
      child: DemoViewportScope(
        mode: _viewport,
        child: widget.preview,
      ),
    );

    if (wide) {
      return Column(
        children: [
          _TopBar(
            demo: widget.demo,
            supportsViewportToggle: _supportsViewportToggle,
            viewport: _viewport,
            onViewportChanged: (mode) => setState(() => _viewport = mode),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 65, child: preview),
                SizedBox(
                  width: 360,
                  child: SingleChildScrollView(child: panel),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _TopBar(
          demo: widget.demo,
          supportsViewportToggle: _supportsViewportToggle,
          viewport: _viewport,
          onViewportChanged: (mode) => setState(() => _viewport = mode),
        ),
        Expanded(flex: 3, child: preview),
        Flexible(
          flex: 2,
          child: SingleChildScrollView(child: panel),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.demo,
    required this.supportsViewportToggle,
    required this.viewport,
    required this.onViewportChanged,
  });

  final DemoEntry demo;
  final bool supportsViewportToggle;
  final DemoViewportMode viewport;
  final ValueChanged<DemoViewportMode> onViewportChanged;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;

    return Material(
      color: VStackColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.go('/demo-lab'),
              icon: const Icon(Icons.arrow_back),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    demo.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'VSTACK Showcase — Sample Template',
                    style: TextStyle(color: VStackColors.accent.withValues(alpha: 0.9), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (supportsViewportToggle) ...[
              const SizedBox(width: 8),
              _ViewportToggle(
                viewport: viewport,
                onChanged: onViewportChanged,
                compact: compact,
              ),
            ],
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context.go('/start-project?demo=${demo.slug}'),
              child: Text(compact ? 'Build' : 'Build Like This'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewportToggle extends StatelessWidget {
  const _ViewportToggle({
    required this.viewport,
    required this.onChanged,
    required this.compact,
  });

  final DemoViewportMode viewport;
  final ValueChanged<DemoViewportMode> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VStackColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: VStackColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            icon: Icons.desktop_windows_outlined,
            label: compact ? null : 'Desktop',
            selected: viewport == DemoViewportMode.desktop,
            onTap: () => onChanged(DemoViewportMode.desktop),
          ),
          _ToggleChip(
            icon: Icons.smartphone_outlined,
            label: compact ? null : 'Mobile',
            selected: viewport == DemoViewportMode.mobile,
            onTap: () => onChanged(DemoViewportMode.mobile),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String? label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VStackColors.accent.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: label == null ? 10 : 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? VStackColors.accent : VStackColors.muted),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? VStackColors.accent : VStackColors.muted,
                  ),
                ),
              ],
            ],
          ),
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
      child: SingleChildScrollView(
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
      ),
    );
  }
}
