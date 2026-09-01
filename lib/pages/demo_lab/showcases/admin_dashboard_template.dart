import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class AdminDashboardTemplate extends StatefulWidget {
  const AdminDashboardTemplate({super.key});

  @override
  State<AdminDashboardTemplate> createState() => _AdminDashboardTemplateState();
}

class _AdminDashboardTemplateState extends State<AdminDashboardTemplate> {
  int _nav = 0;
  static const _navItems = ['Dashboard', 'Users', 'Orders', 'Reports', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.desktop,
      title: 'Admin Console',
      child: Row(
        children: [
          Container(
            width: 180,
            color: const Color(0xFF0E1424),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('VSTACK Admin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ),
                ...List.generate(_navItems.length, (i) {
                  final selected = _nav == i;
                  return Material(
                    color: selected ? VStackColors.accent.withValues(alpha: 0.12) : Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _nav = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          _navItems[i],
                          style: TextStyle(
                            color: selected ? VStackColors.accent : VStackColors.muted,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: VStackColors.bg,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_navItems[_nav], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _KpiCard(label: 'Revenue', value: '₹4.2L', delta: '+12%'),
                        _KpiCard(label: 'Users', value: '1,284', delta: '+8%'),
                        _KpiCard(label: 'Orders', value: '342', delta: '+5%'),
                        _KpiCard(label: 'Uptime', value: '99.9%', delta: 'OK'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: VStackColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: VStackColors.border),
                      ),
                      child: DataTable(
                        headingRowHeight: 40,
                        dataRowMinHeight: 36,
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: List.generate(
                          5,
                          (i) => DataRow(
                            cells: [
                              DataCell(Text('#${1000 + i}')),
                              DataCell(Text('Customer ${i + 1}')),
                              DataCell(Text('₹${(i + 1) * 1200}')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: VStackColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Paid', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.delta});

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VStackColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VStackColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: VStackColors.muted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(delta, style: TextStyle(color: VStackColors.accent.withValues(alpha: 0.9), fontSize: 11)),
        ],
      ),
    );
  }
}
