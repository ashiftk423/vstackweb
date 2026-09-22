import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/cta_section.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_back_link.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';
import 'package:vstackweb/widgets/solution_work_card.dart';

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

    final worksIntro = solution.worksIntro ??
        'Posts, reels, and campaigns we are proud of.';

    return PageScroll(
      child: Column(
        children: [
          const PageBackLink(label: 'Back to all Solutions', route: '/solutions'),
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
          if (solution.differentiators.isNotEmpty)
            PageSection(
              top: VStackSpacing.lg,
              child: ScrollReveal(
                id: 'differentiators-$slug',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solution.differentiatorsTitle,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: VStackSpacing.sm),
                    const Text(
                      'We are not a typical “post every day” digital marketing team.',
                      style: TextStyle(color: VStackColors.muted, fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: VStackSpacing.lg),
                    ResponsiveGrid(
                      itemCount: solution.differentiators.length,
                      desktopColumns: 2,
                      tabletColumns: 2,
                      itemBuilder: (context, index) {
                        final d = solution.differentiators[index];
                        return VStackCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: VStackSpacing.sm),
                              Text(
                                d.body,
                                style: const TextStyle(color: VStackColors.muted, height: 1.5, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
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
          if (solution.works.isNotEmpty) ...[
            PageSection(
              top: VStackSpacing.lg,
              bottom: VStackSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest & favorite works',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: VStackSpacing.sm),
                  Text(
                    worksIntro,
                    style: const TextStyle(color: VStackColors.muted, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Cards load as you scroll — on phone: tap to open, hold to preview, swipe for next.',
                    style: TextStyle(color: VStackColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (AppLayout.isMobile(context))
              Padding(
                padding: const EdgeInsets.only(bottom: VStackSpacing.lg),
                child: IgWorksGrid(
                  itemCount: solution.works.length,
                  itemBuilder: (context, index) => SolutionWorkCard(
                    work: solution.works[index],
                    works: solution.works,
                    index: index,
                  ),
                ),
              )
            else
              PageSection(
                top: 0,
                child: ResponsiveGrid(
                  itemCount: solution.works.length,
                  desktopColumns: 3,
                  tabletColumns: 2,
                  mobileColumns: 3,
                  spacing: VStackSpacing.md,
                  itemBuilder: (context, index) => SolutionWorkCard(
                    work: solution.works[index],
                    works: solution.works,
                    index: index,
                  ),
                ),
              ),
          ],
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
        (
          'Do you only do social media and reels?',
          'No. Creative is one part of the system. We lead with business strategy, validation, scripting & shooting with purpose, digital campaigns, and offline activation — not just posting.',
        ),
        (
          'Do you handle offline / street / event marketing?',
          'Yes. Our offline marketing work includes creative ads in walking areas, events, and local programs — coordinated with your online campaigns.',
        ),
        (
          'Do you help validate business, product, or content before launch?',
          'Yes. We validate the business offer, product positioning, and content/message before heavy spend — so campaigns are built on what actually converts.',
        ),
        (
          'Can you still run Meta and Google ads?',
          'Yes — Meta, Google, SEO, and social sit inside the same strategy as production and offline activation.',
        ),
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
