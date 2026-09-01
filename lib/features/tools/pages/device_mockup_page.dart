import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

enum DeviceFrame { iphone, android, laptop, desktop }

class DeviceMockupPage extends StatefulWidget {
  const DeviceMockupPage({super.key});

  @override
  State<DeviceMockupPage> createState() => _DeviceMockupPageState();
}

class _DeviceMockupPageState extends State<DeviceMockupPage> {
  final _key = GlobalKey();
  Uint8List? _screenshot;
  DeviceFrame _device = DeviceFrame.iphone;
  Color _bg = const Color(0xFF1A1F2E);
  double _padding = 24;

  Future<void> _pick() async {
    final files = await ToolUploadArea.pickFiles(type: FileType.image);
    if (files.isEmpty || files.first.bytes == null) return;
    setState(() => _screenshot = files.first.bytes);
  }

  Future<void> _export() async {
    final boundary = _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      downloadBytes(bytes.buffer.asUint8List(), 'vstack-mockup.png', mimeType: 'image/png');
    }
  }

  Size get _frameSize => switch (_device) {
        DeviceFrame.iphone => const Size(280, 560),
        DeviceFrame.android => const Size(280, 560),
        DeviceFrame.laptop => const Size(520, 320),
        DeviceFrame.desktop => const Size(600, 380),
      };

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.deviceMockup,
      child: ToolSplitLayout(
        input: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolUploadArea(onPick: _pick, label: 'Upload Screenshot'),
              const SizedBox(height: VStackSpacing.md),
              DropdownButtonFormField<DeviceFrame>(
                value: _device,
                decoration: const InputDecoration(labelText: 'Device'),
                items: DeviceFrame.values.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => _device = v ?? DeviceFrame.iphone),
              ),
              Slider(value: _padding, min: 8, max: 48, onChanged: (v) => setState(() => _padding = v), label: 'Padding'),
              FilledButton(onPressed: _screenshot == null ? null : _export, child: const Text('Download PNG')),
            ],
          ),
        ),
        preview: Center(
          child: RepaintBoundary(
            key: _key,
            child: Container(
              color: _bg,
              padding: EdgeInsets.all(_padding),
              child: _screenshot == null
                  ? SizedBox(width: _frameSize.width, height: _frameSize.height, child: const Center(child: Text('Preview', style: TextStyle(color: Colors.white54))))
                  : Container(
                      width: _frameSize.width,
                      height: _frameSize.height,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(_device == DeviceFrame.laptop ? 12 : 32),
                        border: Border.all(color: Colors.white24, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 12))],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(_screenshot!, fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
