import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class SaasLandingTemplate extends StatelessWidget {
  const SaasLandingTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'saas',
      child: DemoTemplateScaffold(
        brand: 'CloudStack',
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Scale your business with smart automation',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    const Text(
                      'All-in-one platform for teams that move fast.',
                      style: TextStyle(color: VStackColors.muted),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: () {}, child: const Text('Start Free Trial'))
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(3, (i) {
                    return Container(
                      width: 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: VStackColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: VStackColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.auto_awesome, color: VStackColors.accent.withValues(alpha: 0.9)),
                          const SizedBox(height: 8),
                          Text('Feature ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const Text('Automate workflows', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
                        ],
                      ),
                    ).animate().fadeIn(delay: (300 + i * 100).ms).slideY(begin: 0.08);
                  }),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Starter', 'Pro', 'Enterprise'].map((plan) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: plan == 'Pro' ? VStackColors.accent.withValues(alpha: 0.12) : VStackColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: plan == 'Pro' ? VStackColors.accent : VStackColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(plan, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text('₹${plan == 'Starter' ? '999' : plan == 'Pro' ? '2499' : '4999'}/mo',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
