import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class ScrollStoryDemo extends StatelessWidget {
  const ScrollStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'story',
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ScrollReveal(
              id: 'story-hero',
              offsetY: 24,
              child: const Text('Built for businesses that scale', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ),
            const SizedBox(height: 8),
            ScrollReveal(
              id: 'story-sub',
              delay: const Duration(milliseconds: 80),
              offsetY: 16,
              child: Text('From Kerala startups to pan-India brands — see how we deliver.', style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 14)),
            ),
            const SizedBox(height: 28),
            ...List.generate(3, (i) {
              final product = DemoSampleData.products[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ScrollReveal(
                  id: 'story-$i',
                  delay: Duration(milliseconds: i * 60),
                  slideFromLeft: i.isOdd,
                  offsetY: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                          child: Image.asset(product.image, width: 140, height: 120, fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(['Design', 'Development', 'Launch'][i], style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(['Pixel-perfect UI', 'Scalable architecture', 'Go-live in weeks'][i], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(['Every screen crafted for conversion.', 'Clean code that grows with you.', 'From idea to production smoothly.'][i], style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            ScrollReveal(
              id: 'story-stats',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _Stat(value: '50+', label: 'Projects'),
                    _Stat(value: '98%', label: 'Satisfaction'),
                    _Stat(value: '24/7', label: 'Support'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
