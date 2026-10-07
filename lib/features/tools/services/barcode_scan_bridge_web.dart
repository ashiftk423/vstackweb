import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:vstackweb/features/tools/services/barcode_scan_bridge_stub.dart';

BarcodeScanBridge createBarcodeScanBridge() => BarcodeScanBridgeWeb();

class BarcodeScanBridgeWeb implements BarcodeScanBridge {
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    if (html.document.querySelector('script[data-vstack-barcode]') == null) {
      final script = html.ScriptElement()
        ..dataset['vstackBarcode'] = 'true'
        ..src = 'tools_barcode.js';
      html.document.head!.append(script);
    }
    for (var i = 0; i < 80; i++) {
      if ((html.window as dynamic).VStackBarcode?.isReady == true) {
        _loaded = true;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw StateError('Barcode scanner failed to load');
  }

  Future<BarcodeScanResult?> _run(Map<String, Object?> op, {Duration? timeout}) async {
    await _ensureLoaded();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final completer = Completer<BarcodeScanResult?>();
    late html.EventListener listener;
    listener = (html.Event e) {
      final detail = jsonDecode((e as html.CustomEvent).detail as String) as Map<String, dynamic>;
      if (detail['id'] != id) return;
      html.window.removeEventListener('vstack-barcode-result', listener);
      if (detail['error'] != null) {
        completer.completeError(detail['error'] as String);
      } else if (detail['text'] is String) {
        completer.complete(BarcodeScanResult(
          text: detail['text'] as String,
          format: detail['format'] as String? ?? 'UNKNOWN',
        ));
      } else {
        completer.complete(null);
      }
    };
    html.window.addEventListener('vstack-barcode-result', listener);
    html.window.dispatchEvent(html.CustomEvent('vstack-barcode-op', detail: jsonEncode({'id': id, ...op})));
    if (timeout == null) return completer.future;
    return completer.future.timeout(timeout, onTimeout: () {
      html.window.removeEventListener('vstack-barcode-result', listener);
      throw TimeoutException('Barcode scan timed out');
    });
  }

  @override
  Future<BarcodeScanResult?> decodeImage(List<int> bytes, {String mimeType = 'image/png'}) async {
    final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    try {
      return await _run({'op': 'decode-image', 'blobUrl': url}, timeout: const Duration(seconds: 30));
    } finally {
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Future<BarcodeScanResult?> scanCamera() => _run({'op': 'scan-camera'});
}
