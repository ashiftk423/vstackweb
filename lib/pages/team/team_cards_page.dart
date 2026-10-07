import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/employee_id_card.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class TeamCardsPage extends StatelessWidget {
  const TeamCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'THE TEAM',
            title: 'VStack team ID cards',
            subtitle:
                'Every VStack employee carries a verified ID card. Scan the barcode or QR code on any card to open this page and confirm who they are.',
          ),
          PageSection(
            top: VStackSpacing.lg,
            child: ResponsiveGrid(
              itemCount: content.team.length,
              desktopColumns: 4,
              tabletColumns: 3,
              mobileColumns: 2,
              spacing: VStackSpacing.lg,
              itemBuilder: (context, i) {
                final m = content.team[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => context.go(m.cardPath),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: VStackColors.accent.withValues(alpha: 0.12),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: EmployeeIdCard(member: m, contact: content.contact),
                        ),
                      ),
                    ),
                    const SizedBox(height: VStackSpacing.sm),
                    Text(
                      m.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      m.employeeId,
                      style: const TextStyle(color: VStackColors.muted, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
