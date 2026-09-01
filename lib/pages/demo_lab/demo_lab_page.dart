import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/widgets/demo_card.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class DemoLabPage extends StatelessWidget {
  const DemoLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Demo Lab',
            title: 'Experience what VSTACK can build',
            subtitle: 'Interactive examples — all data is sample/demo only.',
          ),
          PageSection(
            child: ResponsiveGrid(
              itemCount: content.demos.length,
              desktopColumns: 3,
              itemBuilder: (_, i) => DemoCard(demo: content.demos[i]),
            ),
          ),
        ],
      ),
    );
  }
}
