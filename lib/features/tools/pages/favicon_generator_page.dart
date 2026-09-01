import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/services/image_tool_service.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class FaviconGeneratorPage extends StatefulWidget {
  const FaviconGeneratorPage({super.key});

  @override
  State<FaviconGeneratorPage> createState() => _FaviconGeneratorPageState();
}

class _FaviconGeneratorPageState extends State<FaviconGeneratorPage> {
  static const _sizes = [16, 32, 48, 180, 192, 512];
  img.Image? _source;
  final _generated = <int, Uint8List>{};

  Future<void> _pick() async {
    final files = await ToolUploadArea.pickFiles(type: FileType.image);
    if (files.isEmpty || files.first.bytes == null) return;
    final decoded = ImageToolService.decodeBytes(files.first.bytes!);
    setState(() {
      _source = decoded;
      _generated.clear();
      if (decoded != null) {
        for (final s in _sizes) {
          final resized = img.copyResize(decoded, width: s, height: s);
          _generated[s] = Uint8List.fromList(img.encodePng(resized));
        }
      }
    });
  }

  void _downloadAllZip() {
    final archive = Archive();
    for (final e in _generated.entries) {
      archive.addFile(ArchiveFile('icon-${e.key}x${e.key}.png', e.value.length, e.value));
    }
    final zip = ZipEncoder().encode(archive);
    downloadBytes(zip, 'vstack-icons.zip', mimeType: 'application/zip');
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.faviconGenerator,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolUploadArea(onPick: _pick, label: 'Upload Logo', formats: 'PNG • JPG • SVG not supported'),
            if (_generated.isNotEmpty) ...[
              const SizedBox(height: VStackSpacing.lg),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _generated.entries.map((e) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: VStackColors.border), borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(8),
                        child: Image.memory(e.value, width: e.key.toDouble().clamp(32, 96), height: e.key.toDouble().clamp(32, 96)),
                      ),
                      Text('${e.key}×${e.key}', style: const TextStyle(fontSize: 11, color: VStackColors.muted)),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: VStackSpacing.lg),
              FilledButton(onPressed: _downloadAllZip, child: const Text('Download all sizes (ZIP)')),
            ],
          ],
        ),
      ),
    );
  }
}
