import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class WebsiteDemo extends StatelessWidget {
  const WebsiteDemo({super.key, this.title = 'Business Website'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1020),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [VStackColors.accent.withValues(alpha: 0.2), VStackColors.bg],
                ),
              ),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const Text('Professional business website — demo preview', style: TextStyle(color: VStackColors.muted)),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () {}, child: const Text('Get Started')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    width: 280,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: VStackColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VStackColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.star, color: VStackColors.accent.withValues(alpha: 0.8)),
                        const SizedBox(height: 12),
                        Text('Service ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const Text('Sample content block', style: TextStyle(color: VStackColors.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EcommerceDemo extends StatelessWidget {
  const EcommerceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VStackColors.bg,
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (_, i) {
          return Container(
            decoration: BoxDecoration(
              color: VStackColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: VStackColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 40, color: VStackColors.accent.withValues(alpha: 0.7)),
                const SizedBox(height: 8),
                Text('Product ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Text('₹999', style: TextStyle(color: VStackColors.muted)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MobileDemo extends StatefulWidget {
  const MobileDemo({super.key});

  @override
  State<MobileDemo> createState() => _MobileDemoState();
}

class _MobileDemoState extends State<MobileDemo> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 640,
        decoration: BoxDecoration(
          color: VStackColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: VStackColors.border, width: 8),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(['Home', 'Orders', 'Profile'][_tab], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            Expanded(
              child: Center(
                child: Text(
                  'Mobile app demo\nTab ${_tab + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: VStackColors.muted),
                ),
              ),
            ),
            NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
                NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
