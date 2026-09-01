import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vstackweb/pages/demo_lab/services/demo_3d_bridge.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

String resolveWebAssetUrl(String assetPath) {
  if (!kIsWeb) return assetPath;
  final base = Uri.base;
  final path = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
  return base.resolve('assets/$path').toString();
}

class ThreeDCharacterViewer extends StatefulWidget {
  const ThreeDCharacterViewer({
    super.key,
    required this.modelAsset,
    this.overlay,
  });

  final String modelAsset;
  final Widget? overlay;

  @override
  State<ThreeDCharacterViewer> createState() => _ThreeDCharacterViewerState();
}

class _ThreeDCharacterViewerState extends State<ThreeDCharacterViewer> {
  final _bridge = createDemo3dBridge();
  late final String _viewId = 'vstack-3d-${identityHashCode(this)}';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!kIsWeb) {
      setState(() {
        _loading = false;
        _error = '3D preview is available on web.';
      });
      return;
    }
    try {
      final url = resolveWebAssetUrl(widget.modelAsset);
      _bridge.mountViewer(_viewId, url);
      await _bridge.ensureLoaded();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '3D viewer could not load. Try refreshing.';
        });
      }
    }
  }

  @override
  void dispose() {
    _bridge.unmountViewer(_viewId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1020),
      child: Stack(
        children: [
          if (kIsWeb && _error == null)
            HtmlElementView(viewType: _viewId)
          else if (_error != null)
            Center(child: Text(_error!, style: const TextStyle(color: VStackColors.muted))),
          if (_loading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: VStackColors.surface, borderRadius: BorderRadius.circular(16)),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: VStackColors.accent.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  const Text('Loading 3D model…', style: TextStyle(color: VStackColors.muted, fontSize: 13)),
                ],
              ),
            ),
          if (widget.overlay != null)
            Positioned(left: 16, bottom: 16, right: 16, child: widget.overlay!),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Text('Drag to orbit • Scroll to zoom', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class GameAssetShowcase extends StatelessWidget {
  const GameAssetShowcase({super.key, required this.modelAsset});

  final String modelAsset;

  @override
  Widget build(BuildContext context) {
    return ThreeDCharacterViewer(
      modelAsset: modelAsset,
      overlay: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: VStackColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: VStackColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pipeline metadata', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            SizedBox(height: 6),
            Text('Format: GLB (glTF 2.0)', style: TextStyle(color: VStackColors.muted, fontSize: 11)),
            Text('PBR materials • Web-optimized', style: TextStyle(color: VStackColors.muted, fontSize: 11)),
            Text('Ready for game, AR, and web viewers', style: TextStyle(color: VStackColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
