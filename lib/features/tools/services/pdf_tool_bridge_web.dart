import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:vstackweb/features/tools/services/pdf_tool_bridge_stub.dart';

PdfToolBridge createPdfToolBridge() => PdfToolBridgeWeb();

class PdfToolBridgeWeb implements PdfToolBridge {
  bool _loaded = false;

  @override
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (html.document.querySelector('script[data-vstack-pdf]') != null) {
      await _waitReady();
      return;
    }
    final script = html.ScriptElement()
      ..dataset['vstackPdf'] = 'true'
      ..type = 'module'
      ..src = 'tools_pdf.js';
    html.document.head!.append(script);
    await _waitReady();
  }

  Future<void> _waitReady() async {
    for (var i = 0; i < 50; i++) {
      if (_jsReady) {
        _loaded = true;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('PDF library failed to load');
  }

  bool get _jsReady => (html.window as dynamic).VStackPdf?.isReady == true;

  @override
  Future<List<int>> mergePdfs(List<List<int>> files) => _call('merge', {'files': files.map(base64Encode).toList()});

  @override
  Future<List<List<int>>> splitPdf(List<int> file) async {
    final result = await _callRaw('split', {'file': base64Encode(file)});
    return (result['pages'] as List).map((e) => base64Decode(e as String)).toList();
  }

  @override
  Future<List<int>> imagesToPdf(List<List<int>> images) => _call('imagesToPdf', {'images': images.map(base64Encode).toList()});

  Future<List<int>> _call(String op, Map<String, dynamic> payload) async {
    final result = await _callRaw(op, payload);
    return base64Decode(result['data'] as String);
  }

  Future<Map<String, dynamic>> _callRaw(String op, Map<String, dynamic> payload) async {
    await ensureLoaded();
    final completer = Completer<Map<String, dynamic>>();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    late html.EventListener listener;
    listener = (html.Event e) {
      final event = e as html.CustomEvent;
      final detail = jsonDecode(event.detail as String) as Map<String, dynamic>;
      if (detail['id'] != id) return;
      html.window.removeEventListener('vstack-pdf-result', listener);
      if (detail['error'] != null) {
        completer.completeError(detail['error']);
      } else {
        completer.complete(detail);
      }
    };
    html.window.addEventListener('vstack-pdf-result', listener);
    html.window.dispatchEvent(html.CustomEvent('vstack-pdf-op', detail: jsonEncode({
      'id': id,
      'op': op,
      ...payload,
    })));
    return completer.future.timeout(const Duration(seconds: 60));
  }
}
