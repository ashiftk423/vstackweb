import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/section_header.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/solution_card.dart';

class SolutionsHubPage extends StatelessWidget {
  const SolutionsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Solutions',
            title: 'What VSTACK can do for you',
            subtitle: 'Software, marketing, hardware, security, and custom development — choose your path.',
          ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  id: 'all-solutions',
                  tag: 'EXPLORE',
                  title: 'All solutions',
                  subtitle: 'Dedicated pages for every major business need.',
                ),
                const SizedBox(height: VStackSpacing.xl),
                ResponsiveGrid(
                  itemCount: content.solutions.length,
                  desktopColumns: 3,
                  itemBuilder: (_, i) => SolutionCard(solution: content.solutions[i]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
