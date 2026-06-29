import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/theme/responsive.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/responsive_image.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';
import 'package:vstackweb/widgets/section_header.dart';
import 'package:vstackweb/widgets/vstack_logo.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.content});

  final SiteContent content;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scroll = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _workKey = GlobalKey();
  final _teamKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  late String _enquiry;

  @override
  void initState() {
    super.initState();
    _enquiry = widget.content.contact.enquiryTypes.first;
  }

  @override
  void didUpdateWidget(covariant LandingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.contact.enquiryTypes != widget.content.contact.enquiryTypes) {
      _enquiry = widget.content.contact.enquiryTypes.first;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _submitEnquiry() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final contact = widget.content.contact;
    final body = Uri.encodeComponent(
      'Enquiry type: $_enquiry\n\n${_msgCtrl.text.trim()}',
    );
    final subject = Uri.encodeComponent('${widget.content.site.companyName} enquiry from ${_nameCtrl.text.trim()}');
    final mailto =
        'mailto:${contact.email}?subject=$subject&body=$body';
    await _launch(mailto);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening your email app to send the enquiry.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: VStackColors.surfaceLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = AppLayout.isDesktop(context);
    final pad = AppLayout.pagePadding(context);

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: _NavBar(
                  padding: pad,
                  wide: wide,
                  onWork: () => _scrollToSection(_workKey),
                  onTeam: () => _scrollToSection(_teamKey),
                  onContact: () => _scrollToSection(_contactKey),
                ),
              ),
              SliverToBoxAdapter(
                child: _HeroSection(
                  padding: pad,
                  site: widget.content.site,
                  onStartProject: () => _scrollToSection(_contactKey),
                  onViewWork: () => _scrollToSection(_workKey),
                ),
              ),
              SliverToBoxAdapter(
                child: _CapabilitiesSection(
                  padding: pad,
                  capabilities: widget.content.capabilities,
                ),
              ),
              SliverToBoxAdapter(
                child: _AboutSection(
                  padding: pad,
                  about: widget.content.about,
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _workKey,
                  child: _ProjectsSection(
                    padding: pad,
                    projects: widget.content.projects,
                    onOpenLink: _launch,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _teamKey,
                  child: _TeamSection(padding: pad, team: widget.content.team),
                ),
              ),
              SliverToBoxAdapter(
                child: _CtaSection(
                  padding: pad,
                  cta: widget.content.cta,
                  onStartProject: () => _scrollToSection(_contactKey),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _contactKey,
                  child: _ContactSection(
                    padding: pad,
                    contact: widget.content.contact,
                    formKey: _formKey,
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    msgCtrl: _msgCtrl,
                    enquiry: _enquiry,
                    onEnquiry: (v) => setState(() => _enquiry = v),
                    onSubmit: _submitEnquiry,
                    onEmail: () => _launch('mailto:${widget.content.contact.email}'),
                    onWhatsApp: () => _launch('https://wa.me/${widget.content.contact.whatsappNumber}'),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _Footer(companyName: widget.content.site.companyName)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final mobile = AppLayout.isMobile(context);
    final scale = mobile ? 0.55 : 1.0;

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _orb(320 * scale, VStackColors.accent.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: _orb(280 * scale, VStackColors.accent2.withValues(alpha: 0.14)),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.1, 1.1),
          duration: 6.seconds,
        )
        .moveY(begin: -12, end: 12, duration: 8.seconds);
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.padding,
    required this.wide,
    required this.onWork,
    required this.onTeam,
    required this.onContact,
  });

  final double padding;
  final bool wide;
  final VoidCallback onWork;
  final VoidCallback onTeam;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final links = [
      ('Work', onWork),
      ('Team', onTeam),
      ('Contact', onContact),
    ];

    final compact = AppLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 8),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VStackLogo(size: compact ? 38 : 42, showLabel: !compact, compact: compact),
            ],
          ),
          const Spacer(),
          if (wide)
            ...links.map(
              (l) => TextButton(
                onPressed: l.$2,
                child: Text(l.$1, style: const TextStyle(color: VStackColors.muted)),
              ),
            ),
          FilledButton(
            onPressed: onContact,
            style: FilledButton.styleFrom(
              backgroundColor: VStackColors.accent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: 14),
            ),
            child: Text(compact ? 'Quote' : 'Get a quote'),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.padding,
    required this.site,
    required this.onStartProject,
    required this.onViewWork,
  });

  final double padding;
  final SiteInfo site;
  final VoidCallback onStartProject;
  final VoidCallback onViewWork;

  @override
  Widget build(BuildContext context) {
    final titleSize = AppLayout.heroTitleSize(context);
    final mobile = AppLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, mobile ? 24 : 48, padding, mobile ? 32 : 48),
      child: ScrollReveal(
        id: 'hero',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: VStackColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: VStackColors.border),
              ),
              child: Text(
                site.heroBadge,
                style: TextStyle(color: VStackColors.muted, fontSize: mobile ? 11 : 12),
              ),
            ),
            SizedBox(height: mobile ? 20 : 28),
            Text(
              site.heroTitle,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    fontSize: titleSize,
                  ),
            ),
            SizedBox(height: mobile ? 14 : 20),
            Text(
              site.heroSubtitle,
              style: TextStyle(
                color: VStackColors.muted,
                fontSize: mobile ? 16 : 18,
                height: 1.55,
              ),
            ),
            SizedBox(height: mobile ? 24 : 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onStartProject,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Start your project'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 28, vertical: 16),
                    backgroundColor: VStackColors.accent,
                  ),
                ),
                OutlinedButton(
                  onPressed: onViewWork,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VStackColors.text,
                    side: const BorderSide(color: VStackColors.border),
                    padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 24, vertical: 16),
                  ),
                  child: const Text('View our work'),
                ),
              ],
            ),
            SizedBox(height: mobile ? 32 : 48),
            Wrap(
              spacing: mobile ? 24 : 48,
              runSpacing: 16,
              children: site.stats.map((s) => _stat(s.value, s.label)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String n, String l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(n, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        Text(l, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
      ],
    );
  }
}

class _CapabilitiesSection extends StatelessWidget {
  const _CapabilitiesSection({required this.padding, required this.capabilities});

  final double padding;
  final List<Capability> capabilities;

  @override
  Widget build(BuildContext context) {
    return _sectionPad(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            id: 'capabilities-header',
            tag: 'WHAT WE DO',
            title: 'Services & business solutions',
            subtitle: 'Custom software, billing systems, POS, hardware setup, digital marketing, and complete technology support — all under one roof.',
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, c) {
              final cols = AppLayout.gridColumns(context, desktop: 4, tablet: 2);
              final w = (c.maxWidth - (cols - 1) * 16) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: capabilities.asMap().entries.map((e) {
                  final cap = e.value;
                  return SizedBox(
                    width: cols == 1 ? c.maxWidth : w,
                    child: ScrollReveal(
                      id: 'cap-${cap.id}',
                      delay: Duration(milliseconds: 60 * e.key),
                      child: _capCard(cap.title, cap.description, e.key),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _capCard(String title, String desc, int i) {
    final colors = [VStackColors.accent, VStackColors.accent2, Colors.tealAccent, Colors.orangeAccent];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VStackColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VStackColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: colors[i % colors.length], size: 28),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: VStackColors.muted, height: 1.45)),
        ],
      ),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({
    required this.padding,
    required this.projects,
    required this.onOpenLink,
  });

  final double padding;
  final List<Project> projects;
  final Future<void> Function(String url) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final desktop = AppLayout.isDesktop(context);

    return _sectionPad(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            id: 'projects-header',
            tag: 'HOW WE WORK',
            title: 'Our 6-D delivery process',
            subtitle: 'A proven approach from discovery to long-term support — built for reliable business results.',
          ),
          const SizedBox(height: 28),
          if (desktop)
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                separatorBuilder: (context, index) => const SizedBox(width: 18),
                itemBuilder: (context, i) {
                  final p = projects[i];
                  return ScrollReveal(
                    id: 'project-${p.id}',
                    delay: Duration(milliseconds: 80 * i),
                    slideFromLeft: true,
                    child: _ProjectCard(
                      project: p,
                      fullWidth: false,
                      onOpenLink: onOpenLink,
                    ),
                  );
                },
              ),
            )
          else
            Column(
              children: projects.asMap().entries.map((e) {
                final p = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ScrollReveal(
                    id: 'project-${p.id}',
                    delay: Duration(milliseconds: 60 * e.key),
                    child: _ProjectCard(
                      project: p,
                      fullWidth: true,
                      onOpenLink: onOpenLink,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    required this.project,
    required this.fullWidth,
    required this.onOpenLink,
  });

  final Project project;
  final bool fullWidth;
  final Future<void> Function(String url) onOpenLink;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.fullWidth ? double.infinity : 340.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: cardWidth,
        transform: Matrix4.identity()..translateByDouble(0, _hover ? -6.0 : 0, 0, 1),
        padding: EdgeInsets.all(widget.fullWidth ? 20 : 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hover
                ? [VStackColors.surfaceLight, const Color(0xFF1A2848)]
                : [VStackColors.surface, VStackColors.surface],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hover ? VStackColors.accent.withValues(alpha: 0.5) : VStackColors.border,
          ),
          boxShadow: _hover
              ? [BoxShadow(color: VStackColors.accent.withValues(alpha: 0.15), blurRadius: 32)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: widget.fullWidth ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (widget.project.image != null) ...[
              ResponsiveAssetImage(assetPath: widget.project.image!),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: VStackColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.project.category,
                    style: const TextStyle(color: VStackColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(widget.project.year, style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.project.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
            ),
            const SizedBox(height: 10),
            if (widget.fullWidth)
              Text(
                widget.project.description,
                style: const TextStyle(color: VStackColors.muted, height: 1.45, fontSize: 14),
              )
            else
              Expanded(
                child: Text(
                  widget.project.description,
                  style: const TextStyle(color: VStackColors.muted, height: 1.45, fontSize: 14),
                ),
              ),
            const SizedBox(height: 12),
            Text(widget.project.tech, style: const TextStyle(fontSize: 12, color: VStackColors.accent2)),
            if (widget.project.link != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => widget.onOpenLink(widget.project.link!),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View project'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.padding, required this.about});

  final double padding;
  final AboutSection about;

  @override
  Widget build(BuildContext context) {
    final mobile = AppLayout.isMobile(context);
    final paragraphs = about.text.split('\n\n').where((p) => p.trim().isNotEmpty);

    return _sectionPad(
      padding: padding,
      child: ScrollReveal(
        id: 'about-section',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              id: 'about-header',
              tag: about.tag,
              title: about.title,
              subtitle: paragraphs.first,
            ),
            if (paragraphs.length > 1) ...[
              const SizedBox(height: 24),
              ...paragraphs.skip(1).map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        p,
                        style: TextStyle(
                          color: VStackColors.muted,
                          fontSize: mobile ? 15 : 17,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({
    required this.padding,
    required this.cta,
    required this.onStartProject,
  });

  final double padding;
  final CtaSection cta;
  final VoidCallback onStartProject;

  @override
  Widget build(BuildContext context) {
    final mobile = AppLayout.isMobile(context);

    return _sectionPad(
      padding: padding,
      child: ScrollReveal(
        id: 'cta-section',
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(mobile ? 24 : 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                VStackColors.accent.withValues(alpha: 0.18),
                VStackColors.surfaceLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: VStackColors.accent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cta.title,
                style: TextStyle(
                  fontSize: mobile ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                cta.text,
                style: TextStyle(
                  color: VStackColors.muted,
                  fontSize: mobile ? 15 : 17,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStartProject,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Start your project'),
                style: FilledButton.styleFrom(
                  backgroundColor: VStackColors.accent,
                  padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 28, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection({required this.padding, required this.team});

  final double padding;
  final List<TeamMember> team;

  @override
  Widget build(BuildContext context) {
    return _sectionPad(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            id: 'team-header',
            tag: 'THE PEOPLE',
            title: 'Our leadership & team',
            subtitle: 'The people behind ${team.isNotEmpty ? 'VStack Business Solutions' : 'our company'}.',
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, c) {
              final cols = AppLayout.gridColumns(context, desktop: 4, tablet: 2);
              final w = (c.maxWidth - (cols - 1) * 18) / cols;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: team.asMap().entries.map((e) {
                  final m = e.value;
                  return SizedBox(
                    width: cols == 1 ? c.maxWidth : w,
                    child: ScrollReveal(
                      id: 'team-${m.id}',
                      delay: Duration(milliseconds: 70 * e.key),
                      child: _teamCard(m),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _teamCard(TeamMember m) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: VStackColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: VStackColors.accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamAvatar(member: m),
          const SizedBox(height: 14),
          Text(
            m.isLeadership ? 'LEADERSHIP' : 'TEAM',
            style: const TextStyle(color: VStackColors.accent, fontSize: 10, letterSpacing: 1.2),
          ),
          Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(m.role, style: const TextStyle(color: VStackColors.accent2, fontSize: 13)),
          const SizedBox(height: 10),
          Text(m.bio, style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45)),
        ],
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final radius = AppLayout.isMobile(context) ? 26.0 : 28.0;
    if (member.photo == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: VStackColors.accent,
        child: Text(
          member.initials,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: VStackColors.surfaceLight,
      child: ClipOval(
        child: Image.asset(
          member.photo!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Text(
            member.initials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: member.isLeadership ? VStackColors.accent : VStackColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.padding,
    required this.contact,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.msgCtrl,
    required this.enquiry,
    required this.onEnquiry,
    required this.onSubmit,
    required this.onEmail,
    required this.onWhatsApp,
  });

  final double padding;
  final ContactInfo contact;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController msgCtrl;
  final String enquiry;
  final ValueChanged<String> onEnquiry;
  final Future<void> Function() onSubmit;
  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final split = AppLayout.width(context) >= AppLayout.contactSplitMin;
    final mobile = AppLayout.isMobile(context);

    return _sectionPad(
      padding: padding,
      child: ScrollReveal(
        id: 'contact-section',
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(split ? 40 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(mobile ? 20 : 28),
            gradient: LinearGradient(
              colors: [
                VStackColors.surface,
                VStackColors.surfaceLight.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(color: VStackColors.border),
          ),
          child: split
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _contactInfo(context, onEmail, onWhatsApp)),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _form(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _contactInfo(context, onEmail, onWhatsApp),
                    const SizedBox(height: 28),
                    _form(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _contactInfo(BuildContext context, VoidCallback onEmail, VoidCallback onWhatsApp) {
    final mobile = AppLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GET IN TOUCH', style: TextStyle(color: VStackColors.accent, fontSize: 12, letterSpacing: 2)),
        const SizedBox(height: 12),
        Text(
          'Let\'s talk about your next build',
          style: TextStyle(fontSize: mobile ? 22 : 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pick how you want to reach us — enquiry form, email, or WhatsApp.',
          style: TextStyle(color: VStackColors.muted, height: 1.5),
        ),
        const SizedBox(height: 28),
        _contactTile(Icons.email_outlined, contact.email, 'Email us', onEmail),
        const SizedBox(height: 12),
        _contactTile(Icons.chat_outlined, 'WhatsApp chat', 'Quick questions', onWhatsApp),
        const SizedBox(height: 12),
        _contactTile(Icons.location_on_outlined, contact.location, 'Our location', () {}),
      ],
    );
  }

  Widget _contactTile(IconData icon, String title, String sub, VoidCallback onTap) {
    return Material(
      color: VStackColors.bg.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: VStackColors.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(color: VStackColors.muted, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.arrow_outward, size: 16, color: VStackColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enquiry type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contact.enquiryTypes.map((t) {
              final selected = enquiry == t;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: FilterChip(
                  label: Text(t),
                  selected: selected,
                  onSelected: (_) => onEnquiry(t),
                  selectedColor: VStackColors.accent.withValues(alpha: 0.25),
                  checkmarkColor: VStackColors.accent,
                  labelStyle: TextStyle(
                    color: selected ? VStackColors.text : VStackColors.muted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: selected ? VStackColors.accent : VStackColors.border,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          _field(nameCtrl, 'Your name', Icons.person_outline),
          const SizedBox(height: 14),
          _field(emailCtrl, 'Email address', Icons.alternate_email, email: true),
          const SizedBox(height: 14),
          _field(msgCtrl, 'Tell us about your project', Icons.notes, maxLines: 4),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: VStackColors.accent,
              ),
              child: const Text('Send enquiry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ).animate().shimmer(duration: 2.5.seconds, delay: 1.seconds),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool email = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (email && !v.contains('@')) return 'Enter a valid email';
        return null;
      },
      style: const TextStyle(color: VStackColors.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: VStackColors.muted, size: 20),
        filled: true,
        fillColor: VStackColors.bg.withValues(alpha: 0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VStackColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: VStackColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.companyName});

  final String companyName;

  @override
  Widget build(BuildContext context) {
    final pad = AppLayout.pagePadding(context);
    final mobile = AppLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 40),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '© ${DateTime.now().year} $companyName',
                  style: const TextStyle(color: VStackColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text('Built with Flutter', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
              ],
            )
          : Row(
              children: [
                Text(
                  '© ${DateTime.now().year} $companyName',
                  style: const TextStyle(color: VStackColors.muted, fontSize: 13),
                ),
                const Spacer(),
                const Text('Built with Flutter', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
              ],
            ),
    );
  }
}

Widget _sectionPad({required double padding, required Widget child}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(padding, 48, padding, 24),
    child: child,
  );
}
