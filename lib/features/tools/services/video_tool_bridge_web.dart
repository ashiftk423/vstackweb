import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:vstackweb/features/tools/services/video_tool_bridge_stub.dart';

VideoToolBridge createVideoToolBridge() => VideoToolBridgeWeb();

class VideoToolBridgeWeb implements VideoToolBridge {
  bool _loaded = false;

  @override
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (html.document.querySelector('script[data-vstack-video]') != null) {
      await _waitReady();
      return;
    }
    final script = html.ScriptElement()
      ..dataset['vstackVideo'] = 'true'
      ..type = 'module'
      ..src = 'tools_video.js';
    html.document.head!.append(script);
    await _waitReady();
  }

  Future<void> _waitReady() async {
    for (var i = 0; i < 120; i++) {
      if (_jsReady) {
        _loaded = true;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw StateError('Video compressor library failed to load');
  }

  bool get _jsReady => (html.window as dynamic).VStackVideo?.isReady == true;

  @override
  Future<List<int>> compress(
    List<int> input, {
    required int crf,
    void Function(double progress)? onProgress,
  }) async {
    await ensureLoaded();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final blob = html.Blob([Uint8List.fromList(input)], 'video/mp4');
    final inUrl = html.Url.createObjectUrlFromBlob(blob);

    final completer = Completer<List<int>>();
    late html.EventListener resultListener;
    late html.EventListener progressListener;

    progressListener = (html.Event e) {
      final event = e as html.CustomEvent;
      final detail = jsonDecode(event.detail as String) as Map<String, dynamic>;
      if (detail['id'] != id) return;
      final p = detail['progress'];
      if (p is num) onProgress?.call(p.toDouble().clamp(0.0, 1.0));
    };

    resultListener = (html.Event e) {
      final event = e as html.CustomEvent;
      final detail = jsonDecode(event.detail as String) as Map<String, dynamic>;
      if (detail['id'] != id) return;
      html.window.removeEventListener('vstack-video-result', resultListener);
      html.window.removeEventListener('vstack-video-progress', progressListener);
      html.Url.revokeObjectUrl(inUrl);

      if (detail['error'] != null) {
        completer.completeError(detail['error']);
        return;
      }

      final outUrl = detail['outUrl'] as String?;
      if (outUrl == null) {
        completer.completeError('No output from compressor');
        return;
      }

      html.HttpRequest.request(outUrl, responseType: 'arraybuffer').then((req) {
        html.Url.revokeObjectUrl(outUrl);
        final buffer = req.response as ByteBuffer?;
        if (buffer == null) {
          completer.completeError('Empty compressed video');
          return;
        }
        completer.complete(Uint8List.view(buffer).toList());
      }).catchError((Object err) {
        html.Url.revokeObjectUrl(outUrl);
        completer.completeError(err);
      });
    };

    html.window.addEventListener('vstack-video-result', resultListener);
    html.window.addEventListener('vstack-video-progress', progressListener);
    html.window.dispatchEvent(html.CustomEvent('vstack-video-op', detail: jsonEncode({
      'id': id,
      'op': 'compress',
      'blobUrl': inUrl,
      'crf': crf.clamp(18, 40),
    })));

    return completer.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        html.window.removeEventListener('vstack-video-result', resultListener);
        html.window.removeEventListener('vstack-video-progress', progressListener);
        html.Url.revokeObjectUrl(inUrl);
        throw TimeoutException('Video compression timed out');
      },
    );
  }
}
