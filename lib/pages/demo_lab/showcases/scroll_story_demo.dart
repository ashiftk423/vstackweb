import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class ScrollStoryDemo extends StatelessWidget {
  const ScrollStoryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'story',
      child: Container(
        color: const Color(0xFF0A1020),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ScrollReveal(
              id: 'story-hero',
              child: const Text(
                'Scroll-driven storytelling',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            ScrollReveal(
              id: 'story-sub',
              delay: const Duration(milliseconds: 100),
              child: const Text(
                'Sections animate in as you scroll — perfect for landing pages and product launches.',
                style: TextStyle(color: VStackColors.muted, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ScrollReveal(
                  id: 'story-block-$i',
                  delay: Duration(milliseconds: i * 80),
                  slideFromLeft: i.isOdd,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VStackColors.accent.withValues(alpha: 0.08 + i * 0.04),
                          VStackColors.surface,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VStackColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: VStackColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chapter ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                'Staggered reveal with viewport detection — replays when scrolling back.',
                                style: TextStyle(color: VStackColors.muted.withValues(alpha: 0.9), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            ScrollReveal(
              id: 'story-cta',
              child: Center(
                child: FilledButton(onPressed: () {}, child: const Text('See it on your project')),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
