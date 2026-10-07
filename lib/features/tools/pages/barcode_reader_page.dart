import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/barcode_scan_bridge.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class BarcodeReaderPage extends StatefulWidget {
  const BarcodeReaderPage({super.key});

  @override
  State<BarcodeReaderPage> createState() => _BarcodeReaderPageState();
}

class _BarcodeReaderPageState extends State<BarcodeReaderPage> {
  final _bridge = createBarcodeScanBridge();
  final _history = <BarcodeScanResult>[];
  bool _busy = false;
  String? _error;
  String? _info;

  BarcodeScanResult? get _latest => _history.isEmpty ? null : _history.first;

  Future<void> _run(Future<BarcodeScanResult?> Function() scan, {required String notFound}) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      final result = await scan();
      if (!mounted) return;
      setState(() {
        if (result == null) {
          _info = notFound;
        } else {
          _history.insert(0, result);
          if (_history.length > 10) _history.removeLast();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scanCamera() => _run(_bridge.scanCamera, notFound: 'Scan cancelled.');

  Future<void> _pickImage() async {
    final files = await ToolUploadArea.pickFiles(type: FileType.image);
    if (files.isEmpty || files.first.bytes == null) return;
    final f = files.first;
    final ext = (f.extension ?? 'png').toLowerCase();
    await _run(
      () => _bridge.decodeImage(f.bytes!, mimeType: 'image/${ext == 'jpg' ? 'jpeg' : ext}'),
      notFound: 'No barcode or QR code found in that image. Try a sharper, closer photo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.maybeOf(context);
    final latest = _latest;
    final member = latest == null ? null : content?.memberFromScan(latest.text);

    return ToolPageShell(
      tool: ToolsRegistry.barcodeReader,
      child: ToolSplitLayout(
        input: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _scanCamera,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Scan with camera', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: VStackSpacing.md),
              ToolUploadArea(
                onPick: _busy ? () {} : _pickImage,
                label: 'Upload a photo of a barcode',
                hint: 'Or choose a screenshot / image file',
                formats: 'JPG • PNG • WebP',
              ),
              const SizedBox(height: VStackSpacing.md),
              if (_busy) const Center(child: ToolProcessingIndicator(label: 'Reading…')),
              if (_error != null) ToolStatusMessage(message: _error!, type: ToolMessageType.error),
              if (_info != null) ToolStatusMessage(message: _info!),
            ],
          ),
        ),
        preview: VStackCard(
          child: latest == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, size: 48, color: VStackColors.muted),
                      SizedBox(height: VStackSpacing.sm),
                      Text('Scan results appear here', style: TextStyle(color: VStackColors.muted)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (member != null) ...[
                      _EmployeeMatch(member: member),
                      const SizedBox(height: VStackSpacing.md),
                    ],
                    _ResultTile(result: latest, highlight: true),
                    if (_history.length > 1) ...[
                      const SizedBox(height: VStackSpacing.lg),
                      const Text('Earlier scans', style: TextStyle(color: VStackColors.muted, fontSize: 13)),
                      const SizedBox(height: VStackSpacing.xs),
                      for (final r in _history.skip(1))
                        Padding(
                          padding: const EdgeInsets.only(bottom: VStackSpacing.xs),
                          child: _ResultTile(result: r),
                        ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmployeeMatch extends StatelessWidget {
  const _EmployeeMatch({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF34C759);
    return Container(
      padding: const EdgeInsets.all(VStackSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VStackRadius.md),
        color: green.withValues(alpha: 0.1),
        border: Border.all(color: green.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: VStackColors.accent,
            child: Text(member.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: VStackSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: green, size: 16),
                    SizedBox(width: 4),
                    Text('Verified VStack employee', style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text(member.displayCardName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('${member.employeeId} · ${member.role}',
                    style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.go(member.cardPath),
            child: const Text('Open card'),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, this.highlight = false});

  final BarcodeScanResult result;
  final bool highlight;

  bool get _isLink {
    final uri = Uri.tryParse(result.text.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VStackSpacing.md),
      decoration: BoxDecoration(
        color: VStackColors.surfaceLight,
        borderRadius: BorderRadius.circular(VStackRadius.sm),
        border: Border.all(color: highlight ? VStackColors.accent.withValues(alpha: 0.45) : VStackColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.format.replaceAll('_', ' '),
              style: const TextStyle(color: VStackColors.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 6),
          SelectableText(result.text, style: TextStyle(fontSize: highlight ? 16 : 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: VStackSpacing.sm),
          Wrap(
            spacing: VStackSpacing.xs,
            children: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
              ),
              if (_isLink)
                TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(result.text.trim()), webOnlyWindowName: '_blank'),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open link'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
