import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/cta_section.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class SolutionDetailPage extends StatelessWidget {
  const SolutionDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final solution = content.solutionBySlug(slug);
    if (solution == null) {
      return const Center(child: Text('Solution not found'));
    }

    return PageScroll(
      child: Column(
        children: [
          PageHero(
            compact: true,
            badge: 'Solution',
            title: solution.heroTitle,
            subtitle: solution.heroSubtitle,
            primaryLabel: solution.ctaLabel,
            onPrimary: () => context.go(solution.ctaRoute),
          ),
          PageSection(
            child: ScrollReveal(
              id: 'problem-$slug',
              child: _Block(
                title: 'The problem',
                body: solution.problem,
              ),
            ),
          ),
          PageSection(
            top: VStackSpacing.lg,
            child: ScrollReveal(
              id: 'solution-$slug',
              child: _Block(
                title: 'Our solution',
                body: solution.solutionText,
              ),
            ),
          ),
          PageSection(
            top: VStackSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What we deliver', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: VStackSpacing.lg),
                FeatureGrid(features: solution.features),
              ],
            ),
          ),
          PageSection(
            top: VStackSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Our process', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: VStackSpacing.lg),
                ...solution.process.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: VStackSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: VStackColors.accent.withValues(alpha: 0.2),
                          child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: VStackSpacing.md),
                        Expanded(child: Text(e.value, style: const TextStyle(height: 1.4))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          FaqSection(items: _faqsFor(slug)),
          CtaBanner(
            title: 'Ready to get started?',
            subtitle: 'Tell us about your ${solution.title.toLowerCase()} needs.',
            buttonLabel: solution.ctaLabel,
            route: solution.ctaRoute,
          ),
        ],
      ),
    );
  }

  List<(String, String)> _faqsFor(String slug) {
    return switch (slug) {
      'digital-marketing' => [
        ('Do you manage social media accounts?', 'Yes — content planning, posting, reels, and engagement across platforms.'),
        ('Can you run paid ad campaigns?', 'We manage Meta and Google ad campaigns with strategy, creative, and optimization.'),
      ],
      'cctv-security' => [
        ('Do you provide installation and support?', 'Yes — site survey, installation, configuration, and ongoing maintenance.'),
        ('What types of businesses do you serve?', 'Shops, offices, warehouses, and business premises across Kerala and India.'),
      ],
      'hardware-it' => [
        ('Do you offer AMC support?', 'Yes — annual maintenance contracts for hardware and IT infrastructure.'),
        ('Can you set up complete office IT?', 'We supply and configure computers, printers, networking, and POS hardware.'),
      ],
      _ => [
        ('How do we get started?', 'Use Start a Project or contact us — we\'ll discuss your requirements and propose the best approach.'),
        ('Do you work remotely?', 'Yes — we serve Kerala, India, and clients worldwide.'),
      ],
    };
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: VStackSpacing.md),
        Text(body, style: const TextStyle(color: VStackColors.muted, fontSize: 16, height: 1.6)),
      ],
    );
  }
}
