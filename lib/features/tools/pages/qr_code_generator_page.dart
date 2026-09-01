import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr/qr.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

enum QrType { url, text, phone, email, whatsapp, wifi, upi, vcard, location }

class QrCodeGeneratorPage extends StatefulWidget {
  const QrCodeGeneratorPage({super.key, this.initialData});

  final String? initialData;

  @override
  State<QrCodeGeneratorPage> createState() => _QrCodeGeneratorPageState();
}

class _QrCodeGeneratorPageState extends State<QrCodeGeneratorPage> {
  final _previewKey = GlobalKey();
  QrType _type = QrType.url;
  final _main = TextEditingController(text: 'https://vstackbusinesssolutions.com');
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _ssid = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _upi = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  Color _fg = Colors.black;
  Color _bg = Colors.white;
  double _size = 240;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _main.text = widget.initialData!;
    }
  }

  @override
  void dispose() {
    _main.dispose();
    _phone.dispose();
    _email.dispose();
    _ssid.dispose();
    _password.dispose();
    _name.dispose();
    _upi.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  String get _payload {
    switch (_type) {
      case QrType.url:
        final v = _main.text.trim();
        return v.startsWith('http') ? v : 'https://$v';
      case QrType.text:
        return _main.text;
      case QrType.phone:
        return 'tel:${_phone.text.trim()}';
      case QrType.email:
        return 'mailto:${_email.text.trim()}';
      case QrType.whatsapp:
        final n = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
        return 'https://wa.me/$n?text=${Uri.encodeComponent(_main.text)}';
      case QrType.wifi:
        return 'WIFI:T:WPA;S:${_ssid.text};;P:${_password.text};;';
      case QrType.upi:
        return 'upi://pay?pa=${_upi.text.trim()}&pn=${Uri.encodeComponent(_name.text)}';
      case QrType.vcard:
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:${_name.text}\nTEL:${_phone.text}\nEMAIL:${_email.text}\nEND:VCARD';
      case QrType.location:
        return 'geo:${_lat.text},${_lng.text}';
    }
  }

  Future<void> _downloadPng() async {
    final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      downloadBytes(data.buffer.asUint8List(), 'vstack-qr.png', mimeType: 'image/png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload.trim();
    return ToolPageShell(
      tool: ToolsRegistry.qrCodeGenerator,
      child: ToolSplitLayout(
        input: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: QrType.values.map((t) {
                  return ChoiceChip(
                    label: Text(t.name),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: VStackSpacing.md),
              ..._fields(),
              Slider(value: _size, min: 180, max: 400, divisions: 11, label: 'Size', onChanged: (v) => setState(() => _size = v)),
            ],
          ),
        ),
        preview: VStackCard(
          child: Column(
            children: [
              RepaintBoundary(
                key: _previewKey,
                child: Container(
                  color: _bg,
                  padding: const EdgeInsets.all(16),
                  child: payload.isEmpty
                      ? SizedBox(width: _size, height: _size, child: const Center(child: Text('Enter content')))
                      : CustomPaint(
                          size: Size(_size, _size),
                          painter: _QrPainter(data: payload, fg: _fg, bg: _bg),
                        ),
                ),
              ),
              const SizedBox(height: VStackSpacing.lg),
              ToolDownloadButton(label: 'Download PNG', onPressed: payload.isEmpty ? null : _downloadPng),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fields() {
    switch (_type) {
      case QrType.url:
      case QrType.text:
        return [_tf(_main, _type == QrType.url ? 'URL' : 'Text')];
      case QrType.phone:
        return [_tf(_phone, 'Phone')];
      case QrType.email:
        return [_tf(_email, 'Email')];
      case QrType.whatsapp:
        return [_tf(_phone, 'Phone'), _tf(_main, 'Message (optional)')];
      case QrType.wifi:
        return [_tf(_ssid, 'Network name'), _tf(_password, 'Password')];
      case QrType.upi:
        return [_tf(_upi, 'UPI ID'), _tf(_name, 'Payee name')];
      case QrType.vcard:
        return [_tf(_name, 'Name'), _tf(_phone, 'Phone'), _tf(_email, 'Email')];
      case QrType.location:
        return [_tf(_lat, 'Latitude'), _tf(_lng, 'Longitude')];
    }
  }

  Widget _tf(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(controller: c, decoration: InputDecoration(labelText: label), onChanged: (_) => setState(() {})),
      );
}

class _QrPainter extends CustomPainter {
  _QrPainter({required this.data, required this.fg, required this.bg});
  final String data;
  final Color fg;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final qrCode = QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.H);
    final qrImage = QrImage(qrCode);
    final count = qrImage.moduleCount;
    final module = size.width / count;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bg);
    final paint = Paint()..color = fg;
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(Rect.fromLTWH(col * module, row * module, module, module), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.data != data || old.fg != fg || old.bg != bg;
}
