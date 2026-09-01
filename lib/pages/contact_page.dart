import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/utils/enquiry_launcher.dart';
import 'package:vstackweb/widgets/enquiry_send_buttons.dart';
import 'package:vstackweb/widgets/enquiry_success_view.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/scroll_reveal.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _msg = TextEditingController();
  late String _type;
  String? _sentVia;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _type = SiteContentScope.of(context).contact.enquiryTypes.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _msg.dispose();
    super.dispose();
  }

  String _buildEnquiryMessage() {
    return [
      'VStack website enquiry',
      '',
      'Enquiry type: $_type',
      'Name: ${_name.text.trim()}',
      'Email: ${_email.text.trim()}',
      'Mobile: ${_phone.text.trim()}',
      '',
      'Message:',
      _msg.text.trim(),
    ].join('\n');
  }

  void _markSent(String channel) {
    setState(() => _sentVia = channel);
  }

  void _resetForm() {
    _name.clear();
    _email.clear();
    _phone.clear();
    _msg.clear();
    setState(() {
      _sentVia = null;
      _type = SiteContentScope.of(context).contact.enquiryTypes.first;
    });
  }

  Future<void> _sendViaEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final contact = SiteContentScope.of(context).contact;
    final opened = await EnquiryLauncher.openEmailDraft(
      to: contact.email,
      subject: 'VStack enquiry from ${_name.text.trim()}',
      body: _buildEnquiryMessage(),
    );
    if (mounted && opened) _markSent('email');
  }

  Future<void> _sendViaWhatsApp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final contact = SiteContentScope.of(context).contact;
    final opened = await EnquiryLauncher.openWhatsAppDraft(
      whatsappNumber: contact.whatsappNumber,
      message: _buildEnquiryMessage(),
    );
    if (mounted && opened) _markSent('whatsapp');
  }

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final c = content.contact;
    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Contact',
            title: 'Let\'s talk about your next build',
            subtitle: 'Email, phone, WhatsApp, or send an enquiry below.',
          ),
          PageSection(
            child: ScrollReveal(
              id: 'contact-form',
              child: VStackCard(
                child: _sentVia != null
                    ? EnquirySuccessView(
                        channel: _sentVia!,
                        onNewEnquiry: _resetForm,
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _contactTile(Icons.email_outlined, c.email, () {
                              EnquiryLauncher.openEmailDraft(
                                to: c.email,
                                subject: 'VStack enquiry',
                                body: '',
                              );
                            }),
                            const SizedBox(height: VStackSpacing.sm),
                            _contactTile(
                              Icons.phone_outlined,
                              c.phoneDisplay ?? c.whatsappNumber,
                              () => launchUrl(Uri.parse('tel:${c.whatsappNumber}')),
                            ),
                            const SizedBox(height: VStackSpacing.sm),
                            _contactTile(Icons.chat_outlined, 'WhatsApp', () {
                              EnquiryLauncher.openWhatsAppDraft(
                                whatsappNumber: c.whatsappNumber,
                                message: 'Hi VStack, I would like to enquire about your services.',
                              );
                            }),
                            const SizedBox(height: VStackSpacing.xl),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: c.enquiryTypes.map((t) {
                                return FilterChip(
                                  label: Text(t),
                                  selected: _type == t,
                                  onSelected: (_) => setState(() => _type = t),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: VStackSpacing.lg),
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(labelText: 'Your name'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: VStackSpacing.md),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: (v) =>
                                  v == null || !v.contains('@') ? 'Valid email required' : null,
                            ),
                            const SizedBox(height: VStackSpacing.md),
                            TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Mobile number'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                                if (digits.length < 10) return 'Enter a valid mobile number';
                                return null;
                              },
                            ),
                            const SizedBox(height: VStackSpacing.md),
                            TextFormField(
                              controller: _msg,
                              maxLines: 4,
                              decoration: const InputDecoration(labelText: 'Message'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: VStackSpacing.lg),
                            EnquirySendButtons(
                              onEmail: _sendViaEmail,
                              onWhatsApp: _sendViaWhatsApp,
                            ),
                            const SizedBox(height: VStackSpacing.sm),
                            Text(
                              'Your details are pre-filled as a draft — choose Email or WhatsApp to send.',
                              style: TextStyle(
                                color: VStackColors.muted.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: VStackSpacing.md),
                            OutlinedButton(
                              onPressed: () => context.go('/start-project'),
                              child: const Text('Use Start a Project flow'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: VStackColors.accent, size: 20),
          const SizedBox(width: VStackSpacing.sm),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
