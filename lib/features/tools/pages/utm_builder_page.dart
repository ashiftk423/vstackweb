import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class UtmBuilderPage extends StatefulWidget {
  const UtmBuilderPage({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  State<UtmBuilderPage> createState() => _UtmBuilderPageState();
}

class _UtmBuilderPageState extends State<UtmBuilderPage> {
  final _url = TextEditingController(text: 'https://example.com');
  final _source = TextEditingController(text: 'google');
  final _medium = TextEditingController(text: 'cpc');
  final _campaign = TextEditingController(text: 'spring_sale');
  final _term = TextEditingController();
  final _content = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _url.text = widget.initialUrl!;
    }
  }

  @override
  void dispose() {
    _url.dispose();
    _source.dispose();
    _medium.dispose();
    _campaign.dispose();
    _term.dispose();
    _content.dispose();
    super.dispose();
  }

  String get _builtUrl {
    try {
      final base = _url.text.trim();
      if (base.isEmpty) return '';
      final uri = Uri.parse(base.startsWith('http') ? base : 'https://$base');
      final params = <String, String>{
        if (_source.text.trim().isNotEmpty) 'utm_source': _source.text.trim(),
        if (_medium.text.trim().isNotEmpty) 'utm_medium': _medium.text.trim(),
        if (_campaign.text.trim().isNotEmpty) 'utm_campaign': _campaign.text.trim(),
        if (_term.text.trim().isNotEmpty) 'utm_term': _term.text.trim(),
        if (_content.text.trim().isNotEmpty) 'utm_content': _content.text.trim(),
      };
      return uri.replace(queryParameters: {...uri.queryParameters, ...params}).toString();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final built = _builtUrl;
    return ToolPageShell(
      tool: ToolsRegistry.utmBuilder,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _url, decoration: const InputDecoration(labelText: 'Website URL'), onChanged: (_) => setState(() {})),
            const SizedBox(height: VStackSpacing.sm),
            TextField(controller: _source, decoration: const InputDecoration(labelText: 'Campaign source'), onChanged: (_) => setState(() {})),
            const SizedBox(height: VStackSpacing.sm),
            TextField(controller: _medium, decoration: const InputDecoration(labelText: 'Campaign medium'), onChanged: (_) => setState(() {})),
            const SizedBox(height: VStackSpacing.sm),
            TextField(controller: _campaign, decoration: const InputDecoration(labelText: 'Campaign name'), onChanged: (_) => setState(() {})),
            const SizedBox(height: VStackSpacing.sm),
            TextField(controller: _term, decoration: const InputDecoration(labelText: 'Campaign term (optional)'), onChanged: (_) => setState(() {})),
            const SizedBox(height: VStackSpacing.sm),
            TextField(controller: _content, decoration: const InputDecoration(labelText: 'Campaign content (optional)'), onChanged: (_) => setState(() {})),
            const SizedBox(height: VStackSpacing.lg),
            if (built.isNotEmpty) ...[
              const Text('Final tracking URL', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ToolStatusMessage(message: built, type: ToolMessageType.success),
              const SizedBox(height: VStackSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: built));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL copied')));
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(built), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open URL'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/tools/qr-code-generator?data=${Uri.encodeComponent(built)}'),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Generate QR'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
