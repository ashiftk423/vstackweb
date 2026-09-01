import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/app/site_content_scope.dart';
// TODO: Re-enable when gesture camera UI is finished.
// import 'package:vstackweb/features/gesture_mode/gesture_mode_overlay.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/utils/enquiry_launcher.dart';
import 'package:vstackweb/widgets/site_seo_listener.dart';
import 'package:vstackweb/widgets/vstack_logo.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // TODO: Re-enable when gesture camera UI is finished.
  // bool _gestureMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          Column(
            children: [
              const VStackNavbar(
                // onGestureMode: () => setState(() => _gestureMode = true),
              ),
              Expanded(
                child: SiteSeoListener(child: widget.child),
                // TODO: Re-enable gesture overlay when ready.
                // child: _gestureMode
                //     ? GestureModeOverlay(
                //         onClose: () => setState(() => _gestureMode = false),
                //         child: widget.child,
                //       )
                //     : widget.child,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VStackNavbar extends StatefulWidget {
  const VStackNavbar({super.key, this.onGestureMode});

  /// When set, shows the Gesture Mode button in the nav bar.
  final VoidCallback? onGestureMode;

  @override
  State<VStackNavbar> createState() => _VStackNavbarState();
}

class _VStackNavbarState extends State<VStackNavbar> {
  bool _menuOpen = false;

  static const _links = [
    ('Solutions', '/solutions'),
    ('Products', '/products'),
    ('Our Work', '/work'),
    // TODO: Re-enable when Demo Lab polish is complete.
    // ('Demo Lab', '/demo-lab'),
    ('Tools', '/tools'),
    ('About', '/about'),
    ('Contact', '/contact'),
  ];

  void _nav(String path) {
    setState(() => _menuOpen = false);
    _openSiteLink(context, path);
  }

  @override
  Widget build(BuildContext context) {
    final wide = AppLayout.isDesktop(context);
    final pad = AppLayout.pagePadding(context);
    final location = GoRouterState.of(context).uri.path;

    return Material(
      color: VStackColors.bg.withValues(alpha: 0.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 14),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _nav('/'),
                  borderRadius: BorderRadius.circular(8),
                  child: VStackLogo(
                    size: AppLayout.isMobile(context) ? 36 : 40,
                    showLabel: !AppLayout.isMobile(context),
                    compact: AppLayout.isMobile(context),
                  ),
                ),
                const Spacer(),
                if (wide)
                  ..._links.map((l) {
                    final active = location == l.$2 || location.startsWith('${l.$2}/');
                    return TextButton(
                      onPressed: () => _nav(l.$2),
                      child: Text(
                        l.$1,
                        style: TextStyle(
                          color: active ? VStackColors.text : VStackColors.muted,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                if (!wide)
                  IconButton(
                    onPressed: () => setState(() => _menuOpen = !_menuOpen),
                    icon: Icon(_menuOpen ? Icons.close : Icons.menu),
                    color: VStackColors.text,
                  ),
                if (wide) const SizedBox(width: 8),
                // TODO: Re-enable when gesture camera UI is finished.
                // if (widget.onGestureMode != null)
                //   OutlinedButton(
                //     onPressed: widget.onGestureMode,
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: VStackColors.accent2,
                //       side: BorderSide(color: VStackColors.accent2.withValues(alpha: 0.45)),
                //       padding: EdgeInsets.symmetric(
                //         horizontal: compact ? 10 : 14,
                //         vertical: 14,
                //       ),
                //     ),
                //     child: Text(compact ? '✨' : '✨ Gesture'),
                //   ),
                // if (widget.onGestureMode != null) const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _nav('/start-project'),
                  style: FilledButton.styleFrom(
                    backgroundColor: VStackColors.accent,
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 22 : 14,
                      vertical: 14,
                    ),
                  ),
                  child: Text(wide ? 'Start a Project' : 'Start'),
                ),
              ],
            ),
          ),
          if (!wide && _menuOpen)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _links
                    .map(
                      (l) => TextButton(
                        onPressed: () => _nav(l.$2),
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(l.$1, style: const TextStyle(fontSize: 16)),
                      ),
                    )
                    .toList(),
              ),
            ),
          const Divider(height: 1, color: VStackColors.border),
        ],
      ),
    );
  }
}

class VStackFooter extends StatelessWidget {
  const VStackFooter();

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final pad = AppLayout.pagePadding(context);
    final mobile = AppLayout.isMobile(context);

    Widget linkCol(String title, List<(String, String)> links) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),
          ...links.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => _openSiteLink(context, l.$2),
                child: Text(l.$1, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
              ),
            ),
          ),
        ],
      );
    }

    final solutionLinks = content.solutions
        .where((s) => s.showOnHome)
        .map((s) => (s.title, '/solutions/${s.slug}'))
        .toList();
    final productLinks = content.products.map((p) => (p.name, '/products/${p.slug}')).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(pad, 32, pad, 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: VStackColors.border)),
        color: VStackColors.surface,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.site.companyName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Technology solutions designed around the way your business works.',
                style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              FooterContactButtons(contact: content.contact),
              const SizedBox(height: 24),
              if (mobile) ...[
                linkCol('Solutions', solutionLinks),
                const SizedBox(height: 20),
                linkCol('Products', productLinks),
                const SizedBox(height: 20),
                linkCol('Company', [
                  ('About', '/about'),
                  ('Our Work', '/work'),
                  ('Careers', '/careers'),
                  ('Contact', '/contact'),
                  ('FAQ', '/faq.html'),
                  ('Locations', '/locations.html'),
                ]),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: linkCol('Solutions', solutionLinks)),
                    Expanded(child: linkCol('Products', productLinks)),
                    Expanded(
                      child: linkCol('Company', [
                        ('About', '/about'),
                        ('Our Work', '/work'),
                        ('Careers', '/careers'),
                        ('Contact', '/contact'),
                        ('FAQ', '/faq.html'),
                        ('Locations', '/locations.html'),
                      ]),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Text(
                '© ${DateTime.now().year} ${content.site.companyName} · ${content.contact.location}',
                style: const TextStyle(color: VStackColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FooterContactButtons extends StatelessWidget {
  const FooterContactButtons({super.key, required this.contact});

  final ContactInfo contact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _FooterContactButton(
          icon: Icons.phone_outlined,
          label: 'Call',
          onTap: () => launchUrl(Uri.parse('tel:${contact.whatsappNumber}')),
        ),
        _FooterContactButton(
          icon: Icons.chat_outlined,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () => EnquiryLauncher.openWhatsAppDraft(
            whatsappNumber: contact.whatsappNumber,
            message: 'Hi VStack, I would like to get in touch.',
          ),
        ),
        _FooterContactButton(
          icon: Icons.email_outlined,
          label: 'Mail',
          onTap: () => EnquiryLauncher.openEmailDraft(
            to: contact.email,
            subject: 'VStack enquiry',
            body: '',
          ),
        ),
      ],
    );
  }
}

class _FooterContactButton extends StatelessWidget {
  const _FooterContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? VStackColors.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            color: accent.withValues(alpha: 0.08),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openSiteLink(BuildContext context, String path) {
  if (path.endsWith('.html')) {
    final uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('https://vstackbusinesssolutions.com$path');
    launchUrl(uri, webOnlyWindowName: '_self');
    return;
  }
  context.go(path);
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VStackColors.accent.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VStackColors.accent2.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
