import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/models/enquiry.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/utils/enquiry_launcher.dart';
import 'package:vstackweb/widgets/enquiry_send_buttons.dart';
import 'package:vstackweb/widgets/enquiry_success_view.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

class StartProjectPage extends StatefulWidget {
  const StartProjectPage({
    super.key,
    this.initialService,
    this.initialProduct,
    this.initialDemo,
  });

  final String? initialService;
  final String? initialProduct;
  final String? initialDemo;

  @override
  State<StartProjectPage> createState() => _StartProjectPageState();
}

class _StartProjectPageState extends State<StartProjectPage> {
  int _step = 0;
  late String _requirement;
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  String? _sentVia;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final types = SiteContentScope.of(context).enquiry.requirementTypes;
    _requirement = _mapInitialRequirement(types);
  }

  String _mapInitialRequirement(List<String> types) {
    if (widget.initialService != null) {
      return switch (widget.initialService) {
        'digital-marketing' => 'Digital Marketing',
        'hardware' => 'Hardware',
        'cctv' => 'CCTV',
        'mobile-app' => 'Mobile App',
        'delivery' => 'Delivery Software',
        'software' || 'custom-dev' => 'Custom Software',
        _ => types.first,
      };
    }
    if (widget.initialProduct != null) return 'Custom Software';
    if (widget.initialDemo != null) return 'ERP / Business System';
    return types.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _phone.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  EnquiryPayload _buildPayload() => EnquiryPayload(
        name: _name.text.trim(),
        company: _company.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        requirementType: _requirement,
        service: widget.initialService,
        product: widget.initialProduct,
        demo: widget.initialDemo,
        message: _message.text.trim(),
        source: 'start-project',
      );

  String _buildEnquiryMessage() {
    final payload = _buildPayload();
    final lines = <String>[
      'VStack project enquiry',
      '',
      ...payload.toFields().entries.map((e) => '${_fieldLabel(e.key)}: ${e.value}'),
    ];
    return lines.join('\n');
  }

  String _fieldLabel(String key) => switch (key) {
        'name' => 'Name',
        'company' => 'Company',
        'phone' => 'Phone',
        'email' => 'Email',
        'requirementType' => 'Requirement',
        'service' => 'Service',
        'product' => 'Product',
        'demo' => 'Demo',
        'message' => 'Message',
        'source' => 'Source',
        _ => key,
      };

  bool _validateBeforeSend() {
    if (_name.text.trim().isEmpty) {
      _showValidationError('Please enter your name.');
      return false;
    }
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      _showValidationError('Please enter a valid email.');
      return false;
    }
    if (_message.text.trim().isEmpty) {
      _showValidationError('Please describe your requirement.');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _markSent(String channel) {
    setState(() => _sentVia = channel);
  }

  void _resetEnquiry() {
    _name.clear();
    _company.clear();
    _phone.clear();
    _email.clear();
    _message.clear();
    setState(() {
      _sentVia = null;
      _step = 0;
      _requirement = _mapInitialRequirement(
        SiteContentScope.of(context).enquiry.requirementTypes,
      );
    });
  }

  Future<void> _sendViaEmail() async {
    if (!_validateBeforeSend()) return;
    final contact = SiteContentScope.of(context).contact;
    final payload = _buildPayload();
    final opened = await EnquiryLauncher.openEmailDraft(
      to: contact.email,
      subject: 'VStack project enquiry — ${payload.name}',
      body: _buildEnquiryMessage(),
    );
    if (mounted && opened) _markSent('email');
  }

  Future<void> _sendViaWhatsApp() async {
    if (!_validateBeforeSend()) return;
    final contact = SiteContentScope.of(context).contact;
    final opened = await EnquiryLauncher.openWhatsAppDraft(
      whatsappNumber: contact.whatsappNumber,
      message: _buildEnquiryMessage(),
    );
    if (mounted && opened) _markSent('whatsapp');
  }

  @override
  Widget build(BuildContext context) {
    final types = SiteContentScope.of(context).enquiry.requirementTypes;

    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Start a Project',
            title: 'Tell us what you need',
            subtitle: 'A quick enquiry — we\'ll get back to you shortly.',
          ),
          PageSection(
            child: VStackCard(
              child: _sentVia != null
                  ? EnquirySuccessView(
                      channel: _sentVia!,
                      onNewEnquiry: _resetEnquiry,
                    )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_step + 1) / 3,
                    backgroundColor: VStackColors.border,
                    color: VStackColors.accent,
                  ),
                  const SizedBox(height: VStackSpacing.xl),
                  if (_step == 0) ...[
                    const Text('What do you need?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: VStackSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types.map((t) {
                        return ChoiceChip(
                          label: Text(t),
                          selected: _requirement == t,
                          onSelected: (_) => setState(() => _requirement = t),
                        );
                      }).toList(),
                    ),
                  ],
                  if (_step == 1) ...[
                    TextField(controller: _name, decoration: const InputDecoration(labelText: 'Your name')),
                    const SizedBox(height: VStackSpacing.md),
                    TextField(controller: _company, decoration: const InputDecoration(labelText: 'Business name')),
                    const SizedBox(height: VStackSpacing.md),
                    TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
                    const SizedBox(height: VStackSpacing.md),
                    TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                  ],
                  if (_step == 2) ...[
                    TextField(
                      controller: _message,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Tell us about your requirement',
                        hintText: widget.initialProduct != null
                            ? 'Interested in ${widget.initialProduct}'
                            : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: VStackSpacing.xl),
                  if (_step < 2)
                    Row(
                      children: [
                        if (_step > 0)
                          OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => setState(() => _step++),
                          child: const Text('Continue'),
                        ),
                      ],
                    )
                  else ...[
                    EnquirySendButtons(
                      onEmail: _sendViaEmail,
                      onWhatsApp: _sendViaWhatsApp,
                    ),
                    const SizedBox(height: VStackSpacing.sm),
                    Text(
                      'Your enquiry is pre-filled as a draft — choose Email or WhatsApp to send.',
                      style: TextStyle(color: VStackColors.muted.withValues(alpha: 0.9), fontSize: 12),
                    ),
                    const SizedBox(height: VStackSpacing.md),
                    OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
