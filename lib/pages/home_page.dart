import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/cta_section.dart';
// TODO: Re-enable when Demo Lab section is restored on home page.
// import 'package:vstackweb/widgets/demo_card.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/product_card.dart';
import 'package:vstackweb/widgets/project_card.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/section_header.dart';
import 'package:vstackweb/widgets/solution_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);

    return PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHero(
            badge: content.site.heroBadge,
            title: content.site.heroTitle,
            subtitle: content.site.heroSubtitle,
            primaryLabel: 'Explore Solutions',
            onPrimary: () => context.go('/solutions'),
            secondaryLabel: 'Talk to VSTACK',
            onSecondary: () => context.go('/contact'),
          ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  id: 'intent-header',
                  tag: 'START HERE',
                  title: 'What are you looking for?',
                  subtitle: "Tell us what you need and we'll take you to the right solution.",
                ),
                const SizedBox(height: VStackSpacing.xl),
                ResponsiveGrid(
                  itemCount: content.homeSolutions.length,
                  desktopColumns: 3,
                  tabletColumns: 2,
                  itemBuilder: (_, i) => SolutionCard(solution: content.homeSolutions[i]),
                ),
              ],
            ),
          ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  id: 'products-header',
                  tag: 'OUR PRODUCTS',
                  title: 'VSTACK Products',
                  subtitle: 'Software we build and own — designed for real businesses.',
                  trailing: TextButton(
                    onPressed: () => context.go('/products'),
                    child: const Text('View All Products →'),
                  ),
                ),
                const SizedBox(height: VStackSpacing.xl),
                ResponsiveGrid(
                  itemCount: content.products.length,
                  desktopColumns: 3,
                  itemBuilder: (_, i) => ProductCard(product: content.products[i]),
                ),
              ],
            ),
          ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  id: 'work-header',
                  tag: 'SELECTED WORK',
                  title: 'Client solutions we\'ve built',
                  subtitle: 'Custom projects delivered for businesses — not VSTACK-owned products.',
                  trailing: TextButton(
                    onPressed: () => context.go('/work'),
                    child: const Text('View All Work →'),
                  ),
                ),
                const SizedBox(height: VStackSpacing.xl),
                ResponsiveGrid(
                  itemCount: content.work.length,
                  desktopColumns: 2,
                  itemBuilder: (_, i) => ProjectCard(project: content.work[i]),
                ),
              ],
            ),
          ),
          // TODO: Re-enable Demo Lab section when ready.
          // PageSection(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       SectionHeader(
          //         id: 'demo-header',
          //         tag: 'DEMO LAB',
          //         title: 'Experience what VSTACK can build',
          //         subtitle: 'Explore interactive examples of websites, apps, and business systems.',
          //         trailing: TextButton(
          //           onPressed: () => context.go('/demo-lab'),
          //           child: const Text('Enter Demo Lab →'),
          //         ),
          //       ),
          //       const SizedBox(height: VStackSpacing.xl),
          //       ResponsiveGrid(
          //         itemCount: content.featuredDemos.length,
          //         desktopColumns: 3,
          //         itemBuilder: (_, i) => DemoCard(demo: content.featuredDemos[i]),
          //       ),
          //     ],
          //   ),
          // ),
          PageSection(
            child: ScrollReveal(
              id: 'process-home',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    id: 'process-header',
                    tag: 'HOW WE WORK',
                    title: 'Our 6-D delivery process',
                    subtitle: 'A proven process from discovery to delivery.',
                  ),
                  const SizedBox(height: VStackSpacing.lg),
                  Wrap(
                    spacing: VStackSpacing.sm,
                    runSpacing: VStackSpacing.sm,
                    children: content.process
                        .map(
                          (step) => Chip(
                            avatar: CircleAvatar(
                              backgroundColor: VStackColors.accent.withValues(alpha: 0.2),
                              child: Text(step.year, style: const TextStyle(fontSize: 10)),
                            ),
                            label: Text(step.title),
                            side: const BorderSide(color: VStackColors.border),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          CtaBanner(
            title: content.cta.title,
            subtitle: content.cta.text,
            buttonLabel: 'Start a Project',
            route: '/start-project',
          ),
        ],
      ),
    );
  }
}
