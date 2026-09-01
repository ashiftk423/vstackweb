import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tool_presets.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/image_tool_service.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ImageResizerPage extends StatefulWidget {
  const ImageResizerPage({super.key});

  @override
  State<ImageResizerPage> createState() => _ImageResizerPageState();
}

class _ImageResizerPageState extends State<ImageResizerPage> {
  Uint8List? _original;
  Uint8List? _result;
  String _filename = 'resized.jpg';
  int _width = 1080;
  int _height = 1080;
  bool _lockAspect = true;
  String _format = 'jpg';
  String? _error;

  Future<void> _pick() async {
    final files = await ToolUploadArea.pickFiles(type: FileType.image);
    if (files.isEmpty || files.first.bytes == null) return;
    setState(() {
      _original = files.first.bytes;
      _filename = files.first.name;
      _result = null;
      _error = null;
    });
  }

  void _applyPreset(ImagePreset p) {
    setState(() {
      _width = p.width;
      _height = p.height;
    });
    _process();
  }

  void _process() {
    if (_original == null) return;
    try {
      final image = ImageToolService.decodeBytes(_original!);
      if (image == null) {
        setState(() => _error = 'Unsupported image format.');
        return;
      }
      final resized = ImageToolService.resize(image, width: _width, height: _height, maintainAspect: _lockAspect);
      final bytes = _format == 'png'
          ? ImageToolService.compressPng(resized)
          : _format == 'webp'
              ? ImageToolService.encodeWebp(resized)
              : ImageToolService.compressJpeg(resized);
      if (bytes == null) return;
      setState(() {
        _result = Uint8List.fromList(bytes);
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Processing failed. Try another image.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.imageResizer,
      child: ToolSplitLayout(
        input: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolUploadArea(onPick: _pick),
              const SizedBox(height: VStackSpacing.md),
              const Text('Presets', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ToolPresets.socialPresets.map((p) {
                  return ActionChip(
                    label: Text('${p.platform} ${p.label}'),
                    onPressed: () => _applyPreset(p),
                  );
                }).toList(),
              ),
              const SizedBox(height: VStackSpacing.md),
              Row(
                children: [
                  Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Width'), controller: TextEditingController(text: '$_width'), onSubmitted: (v) { _width = int.tryParse(v) ?? _width; _process(); setState(() {}); })),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height'), controller: TextEditingController(text: '$_height'), onSubmitted: (v) { _height = int.tryParse(v) ?? _height; _process(); setState(() {}); })),
                ],
              ),
              SwitchListTile(value: _lockAspect, onChanged: (v) => setState(() => _lockAspect = v), title: const Text('Lock aspect ratio')),
              DropdownButtonFormField<String>(
                value: _format,
                decoration: const InputDecoration(labelText: 'Output format'),
                items: const [
                  DropdownMenuItem(value: 'jpg', child: Text('JPG')),
                  DropdownMenuItem(value: 'png', child: Text('PNG')),
                  DropdownMenuItem(value: 'webp', child: Text('WebP')),
                ],
                onChanged: (v) { if (v != null) setState(() => _format = v); },
              ),
              const SizedBox(height: VStackSpacing.md),
              FilledButton(onPressed: _original == null ? null : _process, child: const Text('Resize')),
            ],
          ),
        ),
        preview: VStackCard(
          child: Column(
            children: [
              if (_error != null) ToolStatusMessage(message: _error!, type: ToolMessageType.error),
              if (_result != null) ...[
                Text('$_width×$_height · ${ImageToolService.formatBytes(_result!.length)}', style: const TextStyle(color: VStackColors.muted)),
                const SizedBox(height: 12),
                ToolDownloadButton(
                  label: 'Download',
                  onPressed: () => ImageToolService.download(_result!, 'resized-$_filename', mimeType: ImageToolService.mimeForExt(_format)),
                ),
              ] else
                const Padding(padding: EdgeInsets.all(24), child: Text('Upload an image to preview', style: TextStyle(color: VStackColors.muted))),
            ],
          ),
        ),
      ),
    );
  }
}
