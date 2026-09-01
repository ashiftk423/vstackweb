import 'package:flutter/material.dart';
import 'package:vstackweb/features/gesture_mode/gesture_web_bridge_web.dart';

class GestureCameraPreview extends StatelessWidget {
  const GestureCameraPreview({
    super.key,
    required this.mounted,
    this.streamActive = false,
  });

  /// When true, mounts the HTML platform view (required before camera can start).
  final bool mounted;

  /// When true, camera stream is live — hides the loading overlay.
  final bool streamActive;

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return Container(
        color: Colors.black26,
        alignment: Alignment.center,
        child: const Text(
          'Press Start Experience',
          style: TextStyle(color: Colors.white54, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          HtmlElementView(viewType: GestureWebBridgeWeb.cameraViewType),
          if (!streamActive)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: const Text(
                'Starting camera…\n(allow permission if prompted)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
