import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/project_card.dart';

class WorkPage extends StatelessWidget {
  const WorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Our Work',
            title: 'Selected client solutions',
            subtitle: 'Custom projects built for clients — separate from VSTACK-owned products.',
          ),
          PageSection(
            child: ResponsiveGrid(
              itemCount: content.work.length,
              desktopColumns: 2,
              itemBuilder: (_, i) => ProjectCard(project: content.work[i]),
            ),
          ),
        ],
      ),
    );
  }
}
