import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final careers = SiteContentScope.of(context).careers;
    return PageScroll(
      child: Column(
        children: [
          PageHero(compact: true, badge: careers.tag, title: careers.title, subtitle: careers.text),
          PageSection(
            child: ResponsiveGrid(
              itemCount: careers.openRoles.length,
              desktopColumns: 2,
              itemBuilder: (_, i) {
                final role = careers.openRoles[i];
                return VStackCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                      Text(role.type, style: const TextStyle(color: VStackColors.accent2, fontSize: 12)),
                      const SizedBox(height: VStackSpacing.sm),
                      Text(role.description, style: const TextStyle(color: VStackColors.muted, height: 1.45)),
                    ],
                  ),
                );
              },
            ),
          ),
          PageSection(
            child: VStackCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Send your CV', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: VStackSpacing.sm),
                  Text(careers.cvNote, style: const TextStyle(color: VStackColors.muted, height: 1.5)),
                  const SizedBox(height: VStackSpacing.sm),
                  SelectableText(careers.cvEmail, style: const TextStyle(color: VStackColors.accent)),
                  const SizedBox(height: VStackSpacing.lg),
                  FilledButton(
                    onPressed: () => launchUrl(Uri.parse(
                      'mailto:${careers.cvEmail}?subject=${Uri.encodeComponent(careers.cvSubject)}',
                    )),
                    child: const Text('Email your CV'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
