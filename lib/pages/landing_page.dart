import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/services/vstack_content_service.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';
import 'package:vstackweb/widgets/section_header.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    required this.content,
    this.service,
    this.firebaseReady = false,
  });

  final SiteContent content;
  final VStackContentService? service;
  final bool firebaseReady;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scroll = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  late String _enquiry;

  @override
  void initState() {
    super.initState();
    _enquiry = widget.content.settings.enquiryTypes.first;
  }

  @override
  void didUpdateWidget(covariant LandingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.settings.enquiryTypes != widget.content.settings.enquiryTypes) {
      _enquiry = widget.content.settings.enquiryTypes.first;
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

  void _scrollTo(double offset) {
    _scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _submitEnquiry() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      if (widget.service != null) {
        await widget.service!.submitEnquiry(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          message: _msgCtrl.text.trim(),
          enquiryType: _enquiry,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thanks ${_nameCtrl.text.trim()}! We\'ll reply within 24 hours.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: VStackColors.surfaceLight,
        ),
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _msgCtrl.clear();
      setState(() => _enquiry = widget.content.settings.enquiryTypes.first);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send: $e'), backgroundColor: Colors.red.shade900),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: _NavBar(wide: wide, onNav: _scrollTo)),
              SliverToBoxAdapter(
                child: _HeroSection(
                  wide: wide,
                  settings: widget.content.settings,
                  onCta: () => _scrollTo(2800),
                ),
              ),
              SliverToBoxAdapter(
                child: _CapabilitiesSection(wide: wide, capabilities: widget.content.capabilities),
              ),
              SliverToBoxAdapter(
                child: _ProjectsSection(wide: wide, projects: widget.content.projects),
              ),
              SliverToBoxAdapter(
                child: _TeamSection(wide: wide, team: widget.content.team),
              ),
              SliverToBoxAdapter(
                child: _ContactSection(
                  wide: wide,
                  settings: widget.content.settings,
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  msgCtrl: _msgCtrl,
                  enquiry: _enquiry,
                  enquiryTypes: widget.content.settings.enquiryTypes,
                  onEnquiry: (v) => setState(() => _enquiry = v),
                  onSubmit: _submitEnquiry,
                  onEmail: () => _launch('mailto:${widget.content.settings.contactEmail}'),
                  onWhatsApp: () => _launch('https://wa.me/${widget.content.settings.whatsappNumber}'),
                ),
              ),
              const SliverToBoxAdapter(child: _Footer()),
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
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _orb(320, VStackColors.accent.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: _orb(280, VStackColors.accent2.withValues(alpha: 0.14)),
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
  const _NavBar({required this.wide, required this.onNav});

  final bool wide;
  final void Function(double) onNav;

  @override
  Widget build(BuildContext context) {
    final links = [
      ('Work', 1400.0),
      ('Team', 2200.0),
      ('Contact', 3200.0),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 48 : 20, 16, wide ? 48 : 20, 8),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [VStackColors.accent, VStackColors.accent2],
                  ),
                ),
                child: const Text('V', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VStack',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Text('IT Solutions', style: TextStyle(color: VStackColors.muted, fontSize: 11)),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (wide)
            ...links.map(
              (l) => TextButton(
                onPressed: () => onNav(l.$2),
                child: Text(l.$1, style: const TextStyle(color: VStackColors.muted)),
              ),
            ),
          FilledButton(
            onPressed: () => onNav(3200),
            style: FilledButton.styleFrom(
              backgroundColor: VStackColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('Get a quote'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.wide, required this.settings, required this.onCta});

  final bool wide;
  final SiteSettings settings;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 20, vertical: wide ? 48 : 28),
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
              settings.heroBadge,
              style: const TextStyle(color: VStackColors.muted, fontSize: 12),
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(),
          const SizedBox(height: 28),
          Text(
            settings.heroTitle,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  fontSize: wide ? 56 : 36,
                ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 700.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          Text(
            settings.heroSubtitle,
            style: const TextStyle(color: VStackColors.muted, fontSize: 18, height: 1.55),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onCta,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Start your project'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  backgroundColor: VStackColors.accent,
                ),
              ).animate().fadeIn(delay: 650.ms).scale(begin: const Offset(0.92, 0.92)),
              OutlinedButton(
                onPressed: onCta,
                style: OutlinedButton.styleFrom(
                  foregroundColor: VStackColors.text,
                  side: const BorderSide(color: VStackColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
                child: const Text('View our work'),
              ).animate().fadeIn(delay: 750.ms),
            ],
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: wide ? 48 : 28,
            runSpacing: 16,
            children: [
              _stat(settings.stat1Value, settings.stat1Label),
              _stat(settings.stat2Value, settings.stat2Label),
              _stat(settings.stat3Value, settings.stat3Label),
            ],
          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
        ],
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
  const _CapabilitiesSection({required this.wide, required this.capabilities});

  final bool wide;
  final List<CapabilityDoc> capabilities;

  @override
  Widget build(BuildContext context) {
    return _sectionPad(
      wide: wide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            tag: 'WHAT WE DO',
            title: 'Capabilities on display',
            subtitle: 'Every section of this site is built to show how we think about product, motion, and engineering.',
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, c) {
              final cols = wide ? 4 : 1;
              final w = (c.maxWidth - (cols - 1) * 16) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: capabilities.asMap().entries.map((e) {
                  final cap = e.value;
                  return SizedBox(
                    width: wide ? w : c.maxWidth,
                    child: ScrollReveal(
                      delay: Duration(milliseconds: 80 * e.key),
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
  const _ProjectsSection({required this.wide, required this.projects});

  final bool wide;
  final List<ProjectDoc> projects;

  @override
  Widget build(BuildContext context) {
    return _sectionPad(
      wide: wide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            tag: 'OUR WORK',
            title: 'Projects we\'ve delivered',
            subtitle: 'Replace these with your real client names and screenshots when ready.',
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: wide ? 260 : 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: projects.length,
              separatorBuilder: (context, index) => const SizedBox(width: 18),
              itemBuilder: (context, i) {
                final p = projects[i];
                return ScrollReveal(
                  delay: Duration(milliseconds: 100 * i),
                  slideFromLeft: true,
                  child: _ProjectCard(doc: p, wide: wide),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.doc, required this.wide});

  final ProjectDoc doc;
  final bool wide;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.wide ? 340.0 : 300.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: w,
        transform: Matrix4.identity()..translateByDouble(0, _hover ? -8.0 : 0, 0, 1),
        padding: const EdgeInsets.all(26),
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
          children: [
            if (widget.doc.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.doc.imageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
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
                    widget.doc.category,
                    style: const TextStyle(color: VStackColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(widget.doc.year, style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.doc.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                widget.doc.description,
                style: const TextStyle(color: VStackColors.muted, height: 1.45, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.doc.tech, style: const TextStyle(fontSize: 12, color: VStackColors.accent2)),
          ],
        ),
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  const _TeamSection({required this.wide, required this.team});

  final bool wide;
  final List<TeamDoc> team;

  @override
  Widget build(BuildContext context) {
    return _sectionPad(
      wide: wide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            tag: 'THE PEOPLE',
            title: 'Owners & team',
            subtitle: 'Introduce your real founders and engineers — names and roles are placeholders.',
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, c) {
              final cols = wide ? 4 : 1;
              final w = (c.maxWidth - (cols - 1) * 18) / cols;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: team.asMap().entries.map((e) {
                  return SizedBox(
                    width: wide ? w : c.maxWidth,
                    child: ScrollReveal(
                      delay: Duration(milliseconds: 90 * e.key),
                      child: _teamCard(e.value),
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

  Widget _teamCard(TeamDoc m) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: VStackColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: m.isLeadership ? VStackColors.accent.withValues(alpha: 0.4) : VStackColors.border,
          width: m.isLeadership ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: m.isLeadership ? VStackColors.accent : VStackColors.surfaceLight,
            backgroundImage: m.photoUrl != null ? NetworkImage(m.photoUrl!) : null,
            child: m.photoUrl == null
                ? Text(
                    m.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: m.isLeadership ? Colors.white : VStackColors.text,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          if (m.isLeadership)
            const Text('LEADERSHIP', style: TextStyle(color: VStackColors.accent, fontSize: 10, letterSpacing: 1.2)),
          Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(m.role, style: const TextStyle(color: VStackColors.accent2, fontSize: 13)),
          const SizedBox(height: 10),
          Text(m.bio, style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45)),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.wide,
    required this.settings,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.msgCtrl,
    required this.enquiry,
    required this.enquiryTypes,
    required this.onEnquiry,
    required this.onSubmit,
    required this.onEmail,
    required this.onWhatsApp,
  });

  final bool wide;
  final SiteSettings settings;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController msgCtrl;
  final String enquiry;
  final List<String> enquiryTypes;
  final ValueChanged<String> onEnquiry;
  final Future<void> Function() onSubmit;
  final VoidCallback onEmail;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return _sectionPad(
      wide: wide,
      child: ScrollReveal(
        child: Container(
          padding: EdgeInsets.all(wide ? 40 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                VStackColors.surface,
                VStackColors.surfaceLight.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(color: VStackColors.border),
          ),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _contactInfo(onEmail, onWhatsApp)),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _form(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _contactInfo(onEmail, onWhatsApp),
                    const SizedBox(height: 32),
                    _form(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _contactInfo(VoidCallback onEmail, VoidCallback onWhatsApp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GET IN TOUCH', style: TextStyle(color: VStackColors.accent, fontSize: 12, letterSpacing: 2)),
        const SizedBox(height: 12),
        const Text('Let\'s talk about your next build', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text(
          'Pick how you want to reach us — enquiry form, email, or WhatsApp.',
          style: TextStyle(color: VStackColors.muted, height: 1.5),
        ),
        const SizedBox(height: 28),
        _contactTile(Icons.email_outlined, settings.contactEmail, 'Email us', onEmail),
        const SizedBox(height: 12),
        _contactTile(Icons.chat_outlined, 'WhatsApp chat', 'Quick questions', onWhatsApp),
        const SizedBox(height: 12),
        _contactTile(Icons.location_on_outlined, 'Kerala, India', 'Remote worldwide', () {}),
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: VStackColors.accent),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(sub, style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_outward, size: 16, color: VStackColors.muted),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3.seconds, color: VStackColors.accent.withValues(alpha: 0.08));
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
            children: enquiryTypes.map((t) {
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
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Row(
        children: [
          Text(
            '© ${DateTime.now().year} VStack IT Solutions',
            style: const TextStyle(color: VStackColors.muted, fontSize: 13),
          ),
          const Spacer(),
          const Text('Built with Flutter', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

Widget _sectionPad({required bool wide, required Widget child}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(wide ? 48 : 20, 56, wide ? 48 : 20, 24),
    child: child,
  );
}
