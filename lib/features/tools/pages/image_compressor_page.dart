import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/image_tool_service.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class _CompressedItem {
  _CompressedItem({
    required this.name,
    required this.originalBytes,
    required this.compressedBytes,
    required this.mime,
  });

  final String name;
  final int originalBytes;
  final Uint8List compressedBytes;
  final String mime;
}

class ImageCompressorPage extends StatefulWidget {
  const ImageCompressorPage({super.key});

  @override
  State<ImageCompressorPage> createState() => _ImageCompressorPageState();
}

class _ImageCompressorPageState extends State<ImageCompressorPage> {
  final _items = <_CompressedItem>[];
  int _quality = 80;
  bool _processing = false;
  String? _error;

  Future<void> _pick() async {
    setState(() { _processing = true; _error = null; });
    try {
      final files = await ToolUploadArea.pickFiles(type: FileType.image, allowMultiple: true);
      final newItems = <_CompressedItem>[];
      for (final f in files) {
        final bytes = f.bytes;
        if (bytes == null) continue;
        if (bytes.length > ImageToolService.maxFileBytes) {
          setState(() => _error = 'File too large: ${f.name}. Max 15 MB.');
          continue;
        }
        final image = ImageToolService.decodeBytes(bytes);
        if (image == null) continue;
        final ext = (f.extension ?? 'jpg').toLowerCase();
        final compressed = ext == 'png'
            ? ImageToolService.compressPng(image)
            : ext == 'webp'
                ? ImageToolService.encodeWebp(image, quality: _quality)
                : ImageToolService.compressJpeg(image, quality: _quality);
        if (compressed == null) continue;
        newItems.add(_CompressedItem(
          name: f.name,
          originalBytes: bytes.length,
          compressedBytes: Uint8List.fromList(compressed),
          mime: ImageToolService.mimeForExt(ext),
        ));
      }
      setState(() => _items.addAll(newItems));
    } catch (_) {
      setState(() => _error = 'We couldn\'t process this file. Try another image.');
    } finally {
      setState(() => _processing = false);
    }
  }

  void _recompress() {
    // Re-run would need original decoded images; for V1 user re-uploads
    setState(() => _items.clear());
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.imageCompressor,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolUploadArea(onPick: _pick, allowMultiple: true),
            const SizedBox(height: VStackSpacing.md),
            Text('Quality: $_quality%', style: const TextStyle(color: VStackColors.muted)),
            Slider(value: _quality.toDouble(), min: 10, max: 100, divisions: 18, onChanged: (v) => setState(() => _quality = v.round())),
            if (_processing) const Padding(padding: EdgeInsets.all(12), child: ToolProcessingIndicator(label: 'Compressing image…')),
            if (_error != null) ...[const SizedBox(height: 8), ToolStatusMessage(message: _error!, type: ToolMessageType.error)],
            if (_items.isNotEmpty) ...[
              const SizedBox(height: VStackSpacing.lg),
              ..._items.map((item) {
                final saved = ImageToolService.savingsPercent(item.originalBytes, item.compressedBytes.length);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ToolResultCard(
                    title: item.name,
                    rows: [
                      ('Original', ImageToolService.formatBytes(item.originalBytes)),
                      ('Compressed', ImageToolService.formatBytes(item.compressedBytes.length)),
                      ('Saved', '$saved%'),
                    ],
                  ),
                );
              }),
              Wrap(
                spacing: 8,
                children: [
                  ToolDownloadButton(
                    label: 'Download All',
                    onPressed: () {
                      for (final item in _items) {
                        ImageToolService.download(item.compressedBytes, 'compressed-${item.name}', mimeType: item.mime);
                      }
                    },
                  ),
                  OutlinedButton(onPressed: _recompress, child: const Text('Clear & start over')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
