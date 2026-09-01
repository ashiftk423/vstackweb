import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class JsonFormatterPage extends StatefulWidget {
  const JsonFormatterPage({super.key});

  @override
  State<JsonFormatterPage> createState() => _JsonFormatterPageState();
}

class _JsonFormatterPageState extends State<JsonFormatterPage> {
  final _input = TextEditingController(text: '{"hello":"world"}');
  String _output = '';
  String? _error;

  void _format({bool minify = false}) {
    setState(() {
      _error = null;
      try {
        final decoded = jsonDecode(_input.text);
        _output = minify ? jsonEncode(decoded) : const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (e) {
        _error = 'Invalid JSON: $e';
        _output = '';
      }
    });
  }

  void _copy() {
    if (_output.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.jsonFormatter,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _input,
              maxLines: 8,
              decoration: const InputDecoration(labelText: 'Paste JSON', alignLabelWithHint: true),
            ),
            const SizedBox(height: VStackSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: () => _format(), child: const Text('Format')),
                OutlinedButton(onPressed: () => _format(minify: true), child: const Text('Minify')),
                OutlinedButton(onPressed: _copy, child: const Text('Copy')),
                OutlinedButton(onPressed: () => setState(() { _input.clear(); _output = ''; _error = null; }), child: const Text('Clear')),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: VStackSpacing.md),
              ToolStatusMessage(message: _error!, type: ToolMessageType.error),
            ],
            if (_output.isNotEmpty) ...[
              const SizedBox(height: VStackSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VStackColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(_output, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
