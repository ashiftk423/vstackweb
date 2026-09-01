import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_viewport_scope.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_website_frame.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class ScrollStoryDemo extends StatelessWidget {
  const ScrollStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = DemoViewportScope.isMobileView(context);

    return DemoWebsiteFrame(
      title: 'story',
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(mobile ? 16 : 24),
          children: [
            ScrollReveal(
              id: 'story-hero',
              offsetY: 24,
              child: Text(
                'Built for businesses that scale',
                style: TextStyle(fontSize: mobile ? 20 : 26, fontWeight: FontWeight.w800, color: DemoThemes.ink),
              ),
            ),
            const SizedBox(height: 8),
            ScrollReveal(
              id: 'story-sub',
              delay: const Duration(milliseconds: 80),
              offsetY: 16,
              child: const Text(
                'From Kerala startups to pan-India brands — see how we deliver.',
                style: TextStyle(color: DemoThemes.inkMuted, height: 1.5, fontSize: 14),
              ),
            ),
            const SizedBox(height: 28),
            ...List.generate(3, (i) {
              final product = DemoSampleData.products[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ScrollReveal(
                  id: 'story-$i',
                  delay: Duration(milliseconds: i * 60),
                  slideFromLeft: i.isOdd && !mobile,
                  offsetY: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: mobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.asset(
                                  product.image,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey.shade300),
                                ),
                              ),
                              _StoryCopy(index: i),
                            ],
                          )
                        : Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                child: Image.asset(
                                  product.image,
                                  width: 140,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 140, height: 120, color: Colors.grey.shade300),
                                ),
                              ),
                              Expanded(child: _StoryCopy(index: i)),
                            ],
                          ),
                  ),
                ),
              );
            }),
            ScrollReveal(
              id: 'story-stats',
              child: Container(
                padding: EdgeInsets.all(mobile ? 16 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade900]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: mobile
                    ? const Column(
                        children: [
                          _Stat(value: '50+', label: 'Projects'),
                          SizedBox(height: 16),
                          _Stat(value: '98%', label: 'Satisfaction'),
                          SizedBox(height: 16),
                          _Stat(value: '24/7', label: 'Support'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
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

class _StoryCopy extends StatelessWidget {
  const _StoryCopy({required this.index});

  final int index;

  static const _titles = ['Design', 'Development', 'Launch'];
  static const _headlines = ['Pixel-perfect UI', 'Scalable architecture', 'Go-live in weeks'];
  static const _descriptions = [
    'Every screen crafted for conversion.',
    'Clean code that grows with you.',
    'From idea to production smoothly.',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titles[index],
            style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            _headlines[index],
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: DemoThemes.ink),
          ),
          const SizedBox(height: 4),
          Text(
            _descriptions[index],
            style: const TextStyle(color: DemoThemes.inkMuted, fontSize: 12, height: 1.4),
          ),
        ],
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
