import 'dart:convert';
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/barcode_view.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class _BarcodeOption {
  const _BarcodeOption(this.label, this.build, this.sample, this.hint, {this.is2d = false});

  final String label;
  final Barcode Function() build;
  final String sample;
  final String hint;
  final bool is2d;
}

final _options = <_BarcodeOption>[
  _BarcodeOption('Code 128', Barcode.code128, 'VBS-OR-0001', 'Letters, numbers and symbols. Best general-purpose barcode.'),
  _BarcodeOption('Code 39', Barcode.code39, 'VSTACK-39', 'Uppercase A–Z, 0–9 and - . \$ / + % space.'),
  _BarcodeOption('Code 93', Barcode.code93, 'VSTACK93', 'Compact alternative to Code 39.'),
  _BarcodeOption('EAN-13', Barcode.ean13, '890123456789', '12 digits (check digit added automatically) or 13 digits.'),
  _BarcodeOption('EAN-8', Barcode.ean8, '1234567', '7 digits (check digit added automatically) or 8 digits.'),
  _BarcodeOption('UPC-A', Barcode.upcA, '01234567890', '11 digits (check digit added automatically) or 12 digits.'),
  _BarcodeOption('ITF', Barcode.itf, '12345678', 'Even number of digits. Used on cartons.'),
  _BarcodeOption('Codabar', Barcode.codabar, '123456', 'Digits and - \$ : / . + — used in libraries and labs.'),
  _BarcodeOption('QR Code', Barcode.qrCode, 'https://vstackbusinesssolutions.com', 'Any text or link.', is2d: true),
  _BarcodeOption('Data Matrix', Barcode.dataMatrix, 'VSTACK-DM-001', 'Small 2D code for parts and packaging.', is2d: true),
  _BarcodeOption('PDF417', Barcode.pdf417, 'VStack Business Solutions', 'Stacked 2D code used on IDs and boarding passes.'),
  _BarcodeOption('Aztec', Barcode.aztec, 'VSTACK-AZTEC', '2D code used on tickets.', is2d: true),
];

class BarcodeGeneratorPage extends StatefulWidget {
  const BarcodeGeneratorPage({super.key, this.initialData});

  final String? initialData;

  @override
  State<BarcodeGeneratorPage> createState() => _BarcodeGeneratorPageState();
}

class _BarcodeGeneratorPageState extends State<BarcodeGeneratorPage> {
  final _previewKey = GlobalKey();
  late final _data = TextEditingController(
    text: (widget.initialData?.isNotEmpty ?? false) ? widget.initialData : _options.first.sample,
  );
  int _optionIndex = 0;
  bool _showText = true;
  double _height = 120;

  _BarcodeOption get _option => _options[_optionIndex];

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  String? _validate(Barcode barcode, String data) {
    if (data.isEmpty) return 'Enter something to encode.';
    try {
      barcode.verify(data);
      return null;
    } on BarcodeException catch (e) {
      return e.message;
    }
  }

  Future<void> _downloadPng() async {
    final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 4);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      downloadBytes(bytes.buffer.asUint8List(), 'vstack-barcode.png', mimeType: 'image/png');
    }
  }

  void _downloadSvg(Barcode barcode, String data, double width) {
    final svg = barcode.toSvg(
      data,
      width: width,
      height: _option.is2d ? width : _height + (_showText ? 24 : 0),
      drawText: _showText && !_option.is2d,
      fontHeight: 18,
    );
    downloadBytes(utf8.encode(svg), 'vstack-barcode.svg', mimeType: 'image/svg+xml');
  }

  @override
  Widget build(BuildContext context) {
    final barcode = _option.build();
    final data = _data.text.trim();
    final error = _validate(barcode, data);
    final barWidth = _option.is2d ? _height * 1.6 : 340.0;
    final barHeight = _option.is2d ? _height * 1.6 : _height;

    return ToolPageShell(
      tool: ToolsRegistry.barcodeGenerator,
      child: ToolSplitLayout(
        input: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Barcode type', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: VStackSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, o) in _options.indexed)
                    ChoiceChip(
                      label: Text(o.label),
                      selected: _optionIndex == i,
                      onSelected: (_) => setState(() {
                        _optionIndex = i;
                        _data.text = o.sample;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: VStackSpacing.md),
              TextField(
                controller: _data,
                decoration: InputDecoration(labelText: 'Data to encode', helperText: _option.hint, helperMaxLines: 2),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: VStackSpacing.md),
              Text('Size', style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
              Slider(
                value: _height,
                min: 60,
                max: 200,
                divisions: 14,
                label: _height.round().toString(),
                onChanged: (v) => setState(() => _height = v),
              ),
              if (!_option.is2d)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show text under barcode'),
                  value: _showText,
                  onChanged: (v) => setState(() => _showText = v),
                ),
            ],
          ),
        ),
        preview: VStackCard(
          child: Column(
            children: [
              if (error != null)
                ToolStatusMessage(message: error, type: ToolMessageType.error)
              else
                FittedBox(
                  child: RepaintBoundary(
                    key: _previewKey,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BarcodeView(barcode: barcode, data: data, width: barWidth, height: barHeight),
                          if (_showText && !_option.is2d) ...[
                            const SizedBox(height: 6),
                            Text(
                              data,
                              style: const TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 2),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: VStackSpacing.lg),
              Wrap(
                spacing: VStackSpacing.sm,
                runSpacing: VStackSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  ToolDownloadButton(label: 'Download PNG', onPressed: error == null ? _downloadPng : null),
                  OutlinedButton.icon(
                    onPressed: error == null ? () => _downloadSvg(barcode, data, barWidth) : null,
                    icon: const Icon(Icons.code_rounded, size: 18),
                    label: const Text('Download SVG'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
