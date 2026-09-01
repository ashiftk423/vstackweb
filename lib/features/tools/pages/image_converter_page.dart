import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/image_tool_service.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class _ConvertedFile {
  _ConvertedFile({required this.name, required this.bytes, required this.ext});
  final String name;
  final Uint8List bytes;
  final String ext;
}

class ImageConverterPage extends StatefulWidget {
  const ImageConverterPage({super.key});

  @override
  State<ImageConverterPage> createState() => _ImageConverterPageState();
}

class _ImageConverterPageState extends State<ImageConverterPage> {
  String _output = 'webp';
  final _results = <_ConvertedFile>[];
  bool _processing = false;
  String? _error;

  Future<void> _pick() async {
    setState(() { _processing = true; _error = null; _results.clear(); });
    try {
      final files = await ToolUploadArea.pickFiles(type: FileType.image, allowMultiple: true);
      for (final f in files) {
        if (f.bytes == null) continue;
        final image = ImageToolService.decodeBytes(f.bytes!);
        if (image == null) continue;
        final bytes = switch (_output) {
          'png' => ImageToolService.compressPng(image),
          'webp' => ImageToolService.encodeWebp(image),
          _ => ImageToolService.compressJpeg(image),
        };
        if (bytes == null) continue;
        final base = f.name.replaceAll(RegExp(r'\.[^.]+$'), '');
        _results.add(_ConvertedFile(name: '$base.$_output', bytes: Uint8List.fromList(bytes), ext: _output));
      }
    } catch (_) {
      _error = 'Conversion failed. Try supported formats.';
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.imageConverter,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _output,
              decoration: const InputDecoration(labelText: 'Output format'),
              items: const [
                DropdownMenuItem(value: 'jpg', child: Text('JPG')),
                DropdownMenuItem(value: 'png', child: Text('PNG')),
                DropdownMenuItem(value: 'webp', child: Text('WebP')),
              ],
              onChanged: (v) => setState(() => _output = v ?? 'webp'),
            ),
            const SizedBox(height: VStackSpacing.md),
            ToolUploadArea(onPick: _pick, label: 'Upload Images', formats: 'JPG • PNG • WebP', allowMultiple: true),
            if (_processing) const Padding(padding: EdgeInsets.all(12), child: ToolProcessingIndicator(label: 'Converting…')),
            if (_error != null) ToolStatusMessage(message: _error!, type: ToolMessageType.error),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: VStackSpacing.lg),
              ToolDownloadButton(
                label: 'Download All (${_results.length})',
                onPressed: () {
                  for (final r in _results) {
                    ImageToolService.download(r.bytes, r.name, mimeType: ImageToolService.mimeForExt(r.ext));
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
