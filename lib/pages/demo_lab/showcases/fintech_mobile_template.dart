import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class FintechMobileTemplate extends StatefulWidget {
  const FintechMobileTemplate({super.key});

  @override
  State<FintechMobileTemplate> createState() => _FintechMobileTemplateState();
}

class _FintechMobileTemplateState extends State<FintechMobileTemplate> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.phone,
      child: Scaffold(
        backgroundColor: VStackColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good morning, Alex', style: TextStyle(color: VStackColors.muted, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [VStackColors.accent, VStackColors.accent.withValues(alpha: 0.6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text('₹48,250.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _tab == 0
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          ...['Swiggy', 'Amazon', 'Salary Credit', 'Electricity'].map(
                            (t) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: VStackColors.surface,
                                child: Text(t[0], style: const TextStyle(fontSize: 12)),
                              ),
                              title: Text(t, style: const TextStyle(fontSize: 14)),
                              subtitle: const Text('Today', style: TextStyle(fontSize: 11)),
                              trailing: Text(
                                t == 'Salary Credit' ? '+₹45,000' : '-₹${t == 'Swiggy' ? '320' : '1,200'}',
                                style: TextStyle(
                                  color: t == 'Salary Credit' ? Colors.greenAccent : VStackColors.muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(child: Text(['Home', 'Pay', 'Cards', 'Profile'][_tab], style: const TextStyle(color: VStackColors.muted))),
              ),
              NavigationBar(
                selectedIndex: _tab,
                onDestinationSelected: (i) => setState(() => _tab = i),
                height: 56,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Pay'),
                  NavigationDestination(icon: Icon(Icons.credit_card), label: 'Cards'),
                  NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
