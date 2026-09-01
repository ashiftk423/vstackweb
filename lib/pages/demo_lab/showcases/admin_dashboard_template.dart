import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';

class AdminDashboardTemplate extends StatefulWidget {
  const AdminDashboardTemplate({super.key});

  @override
  State<AdminDashboardTemplate> createState() => _AdminDashboardTemplateState();
}

class _AdminDashboardTemplateState extends State<AdminDashboardTemplate> {
  int _nav = 0;
  static const _navItems = [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.people_outline, 'Users'),
    (Icons.shopping_bag_outlined, 'Orders'),
    (Icons.bar_chart, 'Reports'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.desktop,
      title: 'Admin Console',
      child: DemoTemplateScaffold(
        theme: DemoThemes.admin(),
        backgroundColor: const Color(0xFFF1F5F9),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 480;
            final sidebarW = narrow ? 56.0 : 200.0;
            return Row(
              children: [
                SizedBox(
                  width: sidebarW,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!narrow)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('VSTACK Admin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2563EB))),
                          )
                        else
                          const SizedBox(height: 12),
                        ...List.generate(_navItems.length, (i) {
                          final sel = _nav == i;
                          return Material(
                            color: sel ? const Color(0xFFEFF6FF) : Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _nav = i),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: narrow ? 8 : 16, vertical: 12),
                                child: narrow
                                    ? Icon(_navItems[i].$1, size: 18, color: sel ? const Color(0xFF2563EB) : const Color(0xFF94A3B8))
                                    : Row(
                                        children: [
                                          Icon(_navItems[i].$1, size: 18, color: sel ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _navItems[i].$2,
                                              style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(narrow ? 12 : 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_navItems[_nav].$2, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: DemoThemes.ink)),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: const [
                              _KpiCard(label: 'Revenue', value: '₹4.2L', delta: '+12%', color: Color(0xFF2563EB)),
                              _KpiCard(label: 'Users', value: '1,284', delta: '+8%', color: Color(0xFF8B5CF6)),
                              _KpiCard(label: 'Orders', value: '342', delta: '+5%', color: Color(0xFF059669)),
                              _KpiCard(label: 'Uptime', value: '99.9%', delta: 'OK', color: Color(0xFF64748B)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                columns: const [
                                  DataColumn(label: Text('Order', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: DemoThemes.inkMuted))),
                                  DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: DemoThemes.inkMuted))),
                                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: DemoThemes.inkMuted))),
                                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: DemoThemes.inkMuted))),
                                ],
                                rows: [
                                  _orderRow('#1042', 'Rahul K.', '₹2,499', 'Paid', const Color(0xFFDCFCE7), const Color(0xFF166534)),
                                  _orderRow('#1041', 'Priya M.', '₹899', 'Shipped', const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
                                  _orderRow('#1040', 'Anil S.', '₹5,499', 'Pending', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  DataRow _orderRow(String id, String name, String amt, String status, Color bg, Color fg) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontSize: 12, color: DemoThemes.inkSecondary))),
      DataCell(Text(name, style: const TextStyle(fontSize: 12, color: DemoThemes.inkSecondary))),
      DataCell(Text(amt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DemoThemes.ink))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      )),
    ]);
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.delta, required this.color});
  final String label;
  final String value;
  final String delta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DemoThemes.ink)),
          Text(delta, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
