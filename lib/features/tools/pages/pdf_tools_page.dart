import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/services/pdf_tool_bridge.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

enum PdfOp { merge, split, imagesToPdf }

class PdfToolsPage extends StatefulWidget {
  const PdfToolsPage({super.key});

  @override
  State<PdfToolsPage> createState() => _PdfToolsPageState();
}

class _PdfToolsPageState extends State<PdfToolsPage> {
  final _bridge = createPdfToolBridge();
  PdfOp _op = PdfOp.merge;
  bool _busy = false;
  String? _error;
  String? _success;

  Future<void> _run(List<PlatformFile> files) async {
    setState(() { _busy = true; _error = null; _success = null; });
    try {
      await _bridge.ensureLoaded();
      final bytes = files.map((f) => f.bytes).whereType<Uint8List>().toList();
      if (bytes.isEmpty) throw 'No valid files selected';

      switch (_op) {
        case PdfOp.merge:
          final out = await _bridge.mergePdfs(bytes.map((b) => b.toList()).toList());
          downloadBytes(out, 'merged.pdf', mimeType: 'application/pdf');
          setState(() => _success = 'Merged PDF ready — check your downloads.');
        case PdfOp.split:
          if (bytes.length != 1) throw 'Select one PDF to split';
          final pages = await _bridge.splitPdf(bytes.first.toList());
          for (var i = 0; i < pages.length; i++) {
            downloadBytes(pages[i], 'page-${i + 1}.pdf', mimeType: 'application/pdf');
          }
          setState(() => _success = 'Split into ${pages.length} files.');
        case PdfOp.imagesToPdf:
          final out = await _bridge.imagesToPdf(bytes.map((b) => b.toList()).toList());
          downloadBytes(out, 'images.pdf', mimeType: 'application/pdf');
          setState(() => _success = 'PDF created from images.');
      }
    } catch (e) {
      setState(() => _error = 'We couldn\'t process this PDF. $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    final type = _op == PdfOp.imagesToPdf ? FileType.image : FileType.custom;
    final files = await ToolUploadArea.pickFiles(
      type: type,
      allowMultiple: _op != PdfOp.split,
      allowedExtensions: _op == PdfOp.imagesToPdf ? null : ['pdf'],
    );
    if (files.isNotEmpty) await _run(files);
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.pdfToolkit,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Processed locally in your browser. Files are not uploaded to a server.', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
            const SizedBox(height: VStackSpacing.md),
            SegmentedButton<PdfOp>(
              segments: const [
                ButtonSegment(value: PdfOp.merge, label: Text('Merge')),
                ButtonSegment(value: PdfOp.split, label: Text('Split')),
                ButtonSegment(value: PdfOp.imagesToPdf, label: Text('Images→PDF')),
              ],
              selected: {_op},
              onSelectionChanged: (s) => setState(() => _op = s.first),
            ),
            const SizedBox(height: VStackSpacing.lg),
            ToolUploadArea(
              onPick: _pick,
              label: _op == PdfOp.imagesToPdf ? 'Upload Images' : 'Upload PDF',
              formats: _op == PdfOp.imagesToPdf ? 'JPG • PNG' : 'PDF',
              allowMultiple: _op != PdfOp.split,
            ),
            if (_busy) const Padding(padding: EdgeInsets.all(12), child: ToolProcessingIndicator(label: 'Processing PDF…')),
            if (_error != null) ...[const SizedBox(height: 8), ToolStatusMessage(message: _error!, type: ToolMessageType.error)],
            if (_success != null) ...[const SizedBox(height: 8), ToolStatusMessage(message: _success!, type: ToolMessageType.success)],
          ],
        ),
      ),
    );
  }
}
