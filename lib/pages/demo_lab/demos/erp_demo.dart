import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ErpDemo extends StatefulWidget {
  const ErpDemo({super.key, this.compact = false});

  final bool compact;

  @override
  State<ErpDemo> createState() => _ErpDemoState();
}

class _ErpDemoState extends State<ErpDemo> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VStackColors.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VStackSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ERP Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: VStackSpacing.md),
            Wrap(
              spacing: 8,
              children: ['Dashboard', 'Sales', 'Inventory', 'Customers', 'Reports']
                  .asMap()
                  .entries
                  .map(
                    (e) => ChoiceChip(
                      label: Text(e.value),
                      selected: _tab == e.key,
                      onSelected: (_) => setState(() => _tab = e.key),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: VStackSpacing.lg),
            ResponsiveGrid(
              itemCount: 4,
              desktopColumns: 4,
              tabletColumns: 2,
              itemBuilder: (_, i) {
                final stats = [
                  ('Sales Today', '₹48,200'),
                  ('Orders', '127'),
                  ('Low Stock', '8 items'),
                  ('Customers', '342'),
                ];
                return VStackCard(
                  padding: const EdgeInsets.all(VStackSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stats[i].$1, style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
                      Text(stats[i].$2, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: VStackSpacing.lg),
            VStackCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tabLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: VStackSpacing.md),
                  ...List.generate(5, (i) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Sample transaction #${1000 + i}'),
                      subtitle: const Text('Demo data — not real customer info'),
                      trailing: Text('₹${(1200 + i * 340)}'),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _tabLabel => switch (_tab) {
        0 => 'Overview metrics',
        1 => 'Recent sales',
        2 => 'Inventory alerts',
        3 => 'Customer activity',
        _ => 'Monthly reports',
      };
}
