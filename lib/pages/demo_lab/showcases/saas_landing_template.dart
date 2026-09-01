import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';

class SaasLandingTemplate extends StatelessWidget {
  const SaasLandingTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'cloudstack',
      child: DemoTemplateScaffold(
        theme: DemoThemes.saas(),
        backgroundColor: Colors.white,
        header: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const Text('CloudStack', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF635BFF))),
              const Spacer(),
              const Text('Features', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(width: 20),
              const Text('Pricing', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(width: 20),
              OutlinedButton(onPressed: () {}, child: const Text('Sign in')),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, child: const Text('Start free trial')),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF635BFF).withValues(alpha: 0.06), Colors.white],
                    begin: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Now with AI automation', style: TextStyle(fontSize: 12, color: Color(0xFF635BFF), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Financial infrastructure\nfor modern teams', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    const Text('Payments, billing, and analytics — one platform to grow your business.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(onPressed: () {}, child: const Text('Start now')),
                        const SizedBox(width: 12),
                        OutlinedButton(onPressed: () {}, child: const Text('Contact sales')),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Acme', 'Globex', 'Initech', 'Umbrella'].map((l) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(l, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700, fontSize: 16)),
                  )).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    _FeatureCard(icon: Icons.bolt, title: 'Fast setup', desc: 'Go live in minutes with guided onboarding.'),
                    const SizedBox(width: 16),
                    _FeatureCard(icon: Icons.security, title: 'Enterprise security', desc: 'SOC 2 compliant with role-based access.'),
                    const SizedBox(width: 16),
                    _FeatureCard(icon: Icons.insights, title: 'Real-time analytics', desc: 'Dashboards that update as you grow.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PriceCard(name: 'Starter', price: '\$29', highlight: false),
                    const SizedBox(width: 16),
                    _PriceCard(name: 'Pro', price: '\$79', highlight: true),
                    const SizedBox(width: 16),
                    _PriceCard(name: 'Enterprise', price: 'Custom', highlight: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.desc});
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF635BFF)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.name, required this.price, required this.highlight});
  final String name;
  final String price;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF635BFF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? const Color(0xFF635BFF) : Colors.grey.shade200),
        boxShadow: highlight ? [BoxShadow(color: const Color(0xFF635BFF).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))] : null,
      ),
      child: Column(
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: highlight ? Colors.white70 : const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Text(price, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: highlight ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text('/month', style: TextStyle(fontSize: 12, color: highlight ? Colors.white60 : const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
