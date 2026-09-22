import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/services/video_tool_bridge.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

abstract final class VideoToolService {
  static const maxFileBytes = 100 * 1024 * 1024; // 100 MB

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static int savingsPercent(int original, int compressed) {
    if (original <= 0) return 0;
    final saved = ((original - compressed) / original * 100).round();
    return saved.clamp(0, 100);
  }

  /// Maps UI quality 10–100 to ffmpeg CRF 40–18 (lower CRF = higher quality).
  static int crfForQuality(int quality) {
    final q = quality.clamp(10, 100);
    return (40 - ((q - 10) / 90 * 22)).round().clamp(18, 40);
  }
}

class VideoCompressorPage extends StatefulWidget {
  const VideoCompressorPage({super.key});

  @override
  State<VideoCompressorPage> createState() => _VideoCompressorPageState();
}

class _VideoCompressorPageState extends State<VideoCompressorPage> {
  final _bridge = createVideoToolBridge();

  int _quality = 70;
  bool _loadingEngine = false;
  bool _processing = false;
  double _progress = 0;
  String? _error;
  String? _fileName;
  int? _originalBytes;
  Uint8List? _compressed;
  String? _status;

  Future<void> _pick() async {
    setState(() {
      _error = null;
      _compressed = null;
      _status = null;
    });
    try {
      final files = await ToolUploadArea.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp4', 'webm', 'mov', 'mkv', 'avi'],
      );
      if (files.isEmpty) return;
      final f = files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        setState(() => _error = 'Could not read that file. Try another video.');
        return;
      }
      if (bytes.length > VideoToolService.maxFileBytes) {
        setState(() => _error = 'File too large (max ${VideoToolService.formatBytes(VideoToolService.maxFileBytes)}).');
        return;
      }
      setState(() {
        _fileName = f.name;
        _originalBytes = bytes.length;
        _loadingEngine = true;
        _processing = true;
        _progress = 0;
        _status = 'Loading compressor engine (first use may take a minute)…';
      });

      await _bridge.ensureLoaded();
      if (!mounted) return;
      setState(() {
        _loadingEngine = false;
        _status = 'Compressing…';
      });

      final crf = VideoToolService.crfForQuality(_quality);
      final out = await _bridge.compress(
        bytes,
        crf: crf,
        onProgress: (p) {
          if (!mounted) return;
          setState(() {
            _progress = p;
            _status = 'Compressing… ${(_progress * 100).round()}%';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _compressed = Uint8List.fromList(out);
        _processing = false;
        _progress = 1;
        _status = 'Done — ready to download.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _loadingEngine = false;
        _error = 'Compression failed. Try a shorter clip or lower quality. ($e)';
        _status = null;
      });
    }
  }

  void _clear() {
    setState(() {
      _fileName = null;
      _originalBytes = null;
      _compressed = null;
      _error = null;
      _status = null;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final original = _originalBytes;
    final compressed = _compressed;

    return ToolPageShell(
      tool: ToolsRegistry.videoCompressor,
      child: VStackCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IgnorePointer(
              ignoring: _processing || _loadingEngine,
              child: Opacity(
                opacity: (_processing || _loadingEngine) ? 0.6 : 1,
                child: ToolUploadArea(
                  onPick: _pick,
                  label: 'Upload Video',
                  hint: 'Runs fully in your browser — nothing is uploaded to a server',
                  formats: 'MP4 • WebM • MOV • MKV (max 100 MB)',
                ),
              ),
            ),
            const SizedBox(height: VStackSpacing.md),
            Text(
              'Quality: $_quality% (CRF ${VideoToolService.crfForQuality(_quality)})',
              style: const TextStyle(color: VStackColors.muted),
            ),
            Slider(
              value: _quality.toDouble(),
              min: 10,
              max: 100,
              divisions: 18,
              onChanged: (_processing || _loadingEngine)
                  ? null
                  : (v) => setState(() => _quality = v.round()),
            ),
            Text(
              'Lower quality = smaller file. First run downloads the compressor engine (~30 MB).',
              style: TextStyle(color: VStackColors.muted.withValues(alpha: 0.8), fontSize: 12),
            ),
            if (_processing || _loadingEngine) ...[
              const SizedBox(height: VStackSpacing.md),
              LinearProgressIndicator(value: _loadingEngine ? null : (_progress > 0 ? _progress : null)),
              const SizedBox(height: 8),
              ToolProcessingIndicator(label: _status ?? 'Working…'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              ToolStatusMessage(message: _error!, type: ToolMessageType.error),
            ],
            if (_status != null && !_processing && _error == null) ...[
              const SizedBox(height: 8),
              ToolStatusMessage(message: _status!, type: ToolMessageType.success),
            ],
            if (original != null && compressed != null) ...[
              const SizedBox(height: VStackSpacing.lg),
              ToolResultCard(
                title: _fileName ?? 'video.mp4',
                rows: [
                  ('Original', VideoToolService.formatBytes(original)),
                  ('Compressed', VideoToolService.formatBytes(compressed.length)),
                  (
                    'Saved',
                    '${VideoToolService.savingsPercent(original, compressed.length)}%',
                  ),
                ],
              ),
              const SizedBox(height: VStackSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ToolDownloadButton(
                    label: 'Download MP4',
                    onPressed: () {
                      final base = (_fileName ?? 'video').replaceAll(RegExp(r'\.[^.]+$'), '');
                      downloadBytes(
                        compressed,
                        'compressed-$base.mp4',
                        mimeType: 'video/mp4',
                      );
                    },
                  ),
                  OutlinedButton(onPressed: _clear, child: const Text('Clear & start over')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
