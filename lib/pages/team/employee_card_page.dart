import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/employee_id_card.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

/// Public verification page opened when an employee ID card is scanned.
class EmployeeCardPage extends StatelessWidget {
  const EmployeeCardPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final member = content.memberByEmployeeId(employeeId);
    if (member == null) return _NotFound(employeeId: employeeId);
    return PageScroll(child: _EmployeeCardView(member: member, contact: content.contact));
  }
}

class _EmployeeCardView extends StatefulWidget {
  const _EmployeeCardView({required this.member, required this.contact});

  final TeamMember member;
  final ContactInfo contact;

  @override
  State<_EmployeeCardView> createState() => _EmployeeCardViewState();
}

class _EmployeeCardViewState extends State<_EmployeeCardView> {
  final _frontKey = GlobalKey();
  final _backKey = GlobalKey();

  Future<void> _download(GlobalKey key, String side) async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    // 856 × 2 = 1712 px wide ≈ 500 dpi on an 85.6 mm card.
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    downloadBytes(
      data.buffer.asUint8List(),
      '${widget.member.employeeId}-$side.png',
      mimeType: 'image/png',
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final mobile = AppLayout.isMobile(context);
    final records = <(String, String)>[
      ('Employee ID', m.employeeId),
      ('Name', m.displayCardName),
      ('Designation', m.role),
      if (m.department != null) ('Department', m.department!),
      if (m.joinedOn != null) ('Joined', m.joinedOn!),
      if (m.validUntil != null) ('Valid until', m.validUntil!),
      if (m.bloodGroup != null) ('Blood group', m.bloodGroup!),
      if (m.email != null) ('Email', m.email!),
      if (m.phone != null) ('Phone', m.phone!),
      ('Status', 'Active'),
    ];

    return Column(
      children: [
        PageSection(
          top: VStackSpacing.xl,
          child: Column(
            children: [
              const _VerifiedBadge(),
              const SizedBox(height: VStackSpacing.lg),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: mobile ? 340 : 400),
                child: FlippableIdCard(member: m, contact: widget.contact),
              ),
              const SizedBox(height: VStackSpacing.sm),
              const Text(
                'Tap the card to flip it',
                style: TextStyle(color: VStackColors.muted, fontSize: 13),
              ),
              const SizedBox(height: VStackSpacing.lg),
              Wrap(
                spacing: VStackSpacing.sm,
                runSpacing: VStackSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: m.cardUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Card link copied')),
                      );
                    },
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Copy card link'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/team'),
                    icon: const Icon(Icons.groups_rounded, size: 18),
                    label: const Text('All team cards'),
                  ),
                ],
              ),
            ],
          ),
        ),
        PageSection(
          top: VStackSpacing.lg,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: VStackCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Employee record', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: VStackSpacing.md),
                  for (final r in records)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: mobile ? 110 : 150,
                            child: Text(r.$1, style: const TextStyle(color: VStackColors.muted, fontSize: 14)),
                          ),
                          Expanded(
                            child: SelectableText(
                              r.$2,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        PageSection(
          top: VStackSpacing.lg,
          bottom: VStackSpacing.section,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Print-ready card', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 4),
              const Text(
                'Download both sides as high-resolution PNGs for printing (CR80 portrait, 54 × 85.6 mm).',
                style: TextStyle(color: VStackColors.muted, fontSize: 13),
              ),
              const SizedBox(height: VStackSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ResponsiveGrid(
                itemCount: 2,
                desktopColumns: 2,
                tabletColumns: 2,
                mobileColumns: 2,
                spacing: VStackSpacing.lg,
                itemBuilder: (context, i) {
                  final front = i == 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EmployeeIdCard(
                        member: m,
                        contact: widget.contact,
                        side: front ? IdCardSide.front : IdCardSide.back,
                        boundaryKey: front ? _frontKey : _backKey,
                      ),
                      const SizedBox(height: VStackSpacing.sm),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () => _download(front ? _frontKey : _backKey, front ? 'front' : 'back'),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: Text(front ? 'Download front' : 'Download back'),
                        ),
                      ),
                    ],
                  );
                },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF34C759);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: green.withValues(alpha: 0.12),
        border: Border.all(color: green.withValues(alpha: 0.45)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: green, size: 18),
          SizedBox(width: 8),
          Text(
            'Verified VStack employee',
            style: TextStyle(color: green, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return PageScroll(
      child: PageSection(
        bottom: VStackSpacing.section,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: VStackCard(
              child: Column(
                children: [
                  const Icon(Icons.gpp_bad_outlined, color: Colors.redAccent, size: 44),
                  const SizedBox(height: VStackSpacing.md),
                  const Text(
                    'Employee not found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: VStackSpacing.xs),
                  Text(
                    'No active VStack employee has the ID "${employeeId.toUpperCase()}". '
                    'This card may be invalid — please contact VStack Business Solutions to confirm.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: VStackColors.muted, height: 1.5),
                  ),
                  const SizedBox(height: VStackSpacing.lg),
                  FilledButton(
                    onPressed: () => context.go('/team'),
                    child: const Text('View all team cards'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
