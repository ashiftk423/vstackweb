import 'package:flutter/material.dart';
import 'package:vstackweb/features/gesture_mode/gesture_camera_preview.dart';
import 'package:vstackweb/features/gesture_mode/gesture_debug_log.dart';
import 'package:vstackweb/features/gesture_mode/gesture_mode_controller.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class GestureDebugPanel extends StatelessWidget {
  const GestureDebugPanel({
    super.key,
    required this.state,
    required this.logs,
    required this.scrollOffset,
    required this.lastPointerDelta,
    required this.pointerEvents,
    required this.cameraActive,
    required this.cameraMounted,
    required this.onClearLogs,
  });

  final GestureInteractionState state;
  final List<GestureDebugEntry> logs;
  final double scrollOffset;
  final Offset lastPointerDelta;
  final int pointerEvents;
  final bool cameraActive;
  final bool cameraMounted;
  final VoidCallback onClearLogs;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return Container(
      width: mobile ? double.infinity : 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        border: Border(
          left: mobile ? BorderSide.none : const BorderSide(color: VStackColors.border),
          top: mobile ? const BorderSide(color: VStackColors.border) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            child: Row(
              children: [
                const Text(
                  'Gesture Debug',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearLogs,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: mobile ? 120 : 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureCameraPreview(
                mounted: cameraMounted,
                streamActive: cameraActive,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _StatsGrid(
              state: state,
              scrollOffset: scrollOffset,
              lastPointerDelta: lastPointerDelta,
              pointerEvents: pointerEvents,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              state.statusMessage,
              style: TextStyle(
                color: _statusColor(state.cameraState),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Live logs', style: TextStyle(color: Colors.white38, fontSize: 10)),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'No events yet.\nMove mouse / hand in view.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    reverse: true,
                    itemCount: logs.length,
                    itemBuilder: (context, i) {
                      final entry = logs[logs.length - 1 - i];
                      return _LogRow(entry: entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(GestureCameraState s) {
    return switch (s) {
      GestureCameraState.ready || GestureCameraState.handDetected => Colors.greenAccent,
      GestureCameraState.poorVisibility || GestureCameraState.searching => Colors.amber,
      GestureCameraState.permissionRequired ||
      GestureCameraState.permissionBlocked ||
      GestureCameraState.unsupported =>
        Colors.redAccent,
      _ => Colors.white70,
    };
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.state,
    required this.scrollOffset,
    required this.lastPointerDelta,
    required this.pointerEvents,
  });

  final GestureInteractionState state;
  final double scrollOffset;
  final Offset lastPointerDelta;
  final int pointerEvents;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _StatChip('Camera', state.cameraState.name),
        _StatChip('Model', state.modelStatus),
        _StatChip('Detect', state.lastDetection),
        _StatChip('Landmarks', state.landmarkCount > 0 ? '${state.landmarkCount}' : 'none'),
        _StatChip('Hand', state.handLabel.isNotEmpty ? state.handLabel : '—'),
        _StatChip('Action', state.lastAction),
        _StatChip('Source', state.inputSource),
        _StatChip('Cursor', '${(state.cursorX * 100).toStringAsFixed(0)}%, ${(state.cursorY * 100).toStringAsFixed(0)}%'),
        _StatChip('Zoom', state.zoom.toStringAsFixed(2)),
        _StatChip('Scroll', scrollOffset.toStringAsFixed(0)),
        _StatChip('FPS', '${state.fps}'),
        _StatChip('Frame', '${state.frameCount}'),
        _StatChip('Δ', '${lastPointerDelta.dx.toStringAsFixed(1)}, ${lastPointerDelta.dy.toStringAsFixed(1)}'),
        _StatChip('Events', '$pointerEvents'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10, color: Colors.white70),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(color: Colors.white38)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});
  final GestureDebugEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.category) {
      GestureLogCategory.camera => Colors.cyanAccent,
      GestureLogCategory.detect => Colors.lightGreenAccent,
      GestureLogCategory.action => Colors.amberAccent,
      GestureLogCategory.response => Colors.orangeAccent,
      GestureLogCategory.error => Colors.redAccent,
      GestureLogCategory.system => Colors.white54,
    };

    final extra = entry.data.entries.map((e) => '${e.key}=${e.value}').join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 10, height: 1.35),
              children: [
                TextSpan(text: '${entry.timeLabel} ', style: const TextStyle(color: Colors.white38)),
                TextSpan(text: '[${entry.category.name}] ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                TextSpan(text: entry.message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          if (extra.isNotEmpty)
            Text(extra, style: const TextStyle(color: Colors.white38, fontSize: 9, height: 1.3)),
        ],
      ),
    );
  }
}
