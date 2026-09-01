import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';

class FintechMobileTemplate extends StatefulWidget {
  const FintechMobileTemplate({super.key});

  @override
  State<FintechMobileTemplate> createState() => _FintechMobileTemplateState();
}

class _FintechMobileTemplateState extends State<FintechMobileTemplate> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DemoThemes.fintech(),
      child: DemoDeviceFrame(
        type: DemoFrameType.phone,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 18, backgroundColor: const Color(0xFF5F259F).withValues(alpha: 0.1), child: const Text('A', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5F259F)))),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          Text('Alex Kumar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5F259F), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF5F259F).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('₹48,250.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: Colors.white70, size: 14),
                            SizedBox(width: 4),
                            Text('VSTACK Pay •••• 4821', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickAction(icon: Icons.send_rounded, label: 'Send'),
                      _QuickAction(icon: Icons.qr_code_scanner, label: 'Scan'),
                      _QuickAction(icon: Icons.phone_android, label: 'Recharge'),
                      _QuickAction(icon: Icons.receipt_long, label: 'Bills'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: DemoSampleData.transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = DemoSampleData.transactions[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text(t.icon, style: const TextStyle(fontSize: 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.merchant, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(t.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text(
                              '${t.isCredit ? '+' : ''}₹${t.amount.abs().toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: t.isCredit ? const Color(0xFF059669) : const Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: (i) => setState(() => _tab = i),
                  height: 56,
                  backgroundColor: Colors.white,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
                    NavigationDestination(icon: Icon(Icons.history), label: 'History'),
                    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
          child: Icon(icon, color: const Color(0xFF5F259F), size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
