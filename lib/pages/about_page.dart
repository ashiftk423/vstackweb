import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/section_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    return PageScroll(
      child: Column(
        children: [
          PageHero(
            compact: true,
            badge: content.about.tag,
            title: content.about.title,
            subtitle: content.about.text.split('\n').first,
          ),
          PageSection(
            child: Text(
              content.about.text,
              style: const TextStyle(color: VStackColors.muted, fontSize: 16, height: 1.65),
            ),
          ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  id: 'team-about',
                  tag: 'THE PEOPLE',
                  title: 'Our leadership & team',
                ),
                const SizedBox(height: VStackSpacing.xl),
                ResponsiveGrid(
                  itemCount: content.team.length,
                  desktopColumns: 3,
                  itemBuilder: (_, i) {
                    final m = content.team[i];
                    return VStackCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: VStackColors.accent,
                            child: Text(m.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: VStackSpacing.md),
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          Text(m.role, style: const TextStyle(color: VStackColors.accent2, fontSize: 12)),
                          const SizedBox(height: VStackSpacing.sm),
                          Text(m.bio, style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
