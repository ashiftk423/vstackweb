import 'package:flutter/material.dart';

import 'package:vstackweb/features/gesture_mode/gesture_camera_preview.dart';

import 'package:vstackweb/features/gesture_mode/gesture_debug_log.dart';

import 'package:vstackweb/features/gesture_mode/gesture_debug_panel.dart';

import 'package:vstackweb/features/gesture_mode/gesture_interaction_mapper.dart';

import 'package:vstackweb/features/gesture_mode/gesture_mode_controller.dart';

import 'package:vstackweb/theme/vstack_theme.dart';

import 'package:vstackweb/widgets/layout_widgets.dart';



class GestureModeOverlay extends StatefulWidget {

  const GestureModeOverlay({

    super.key,

    required this.onClose,

    required this.child,

  });



  final VoidCallback onClose;

  final Widget child;



  @override

  State<GestureModeOverlay> createState() => _GestureModeOverlayState();

}



class _GestureModeOverlayState extends State<GestureModeOverlay> {

  late final GestureModeController _controller = GestureModeController();

  GestureInteractionState _state = const GestureInteractionState(

    cameraState: GestureCameraState.initializing,

    statusMessage: 'Starting...',

  );

  List<GestureDebugEntry> _logs = [];

  double _scrollOffset = 0;

  Offset _lastPointerDelta = Offset.zero;

  int _pointerEvents = 0;

  bool _started = false;

  bool _showDebug = true;



  @override

  void initState() {

    super.initState();

    _controller.prepare();

    _controller.states.listen((s) {

      if (!mounted) return;

      if (s.inputSource == 'hand') _pointerEvents++;

      if (s.inputSource == 'hand' && s.deltaY.abs() > 1.5) {

        _applyScroll(s.deltaY);

      }

      setState(() => _state = s);

    });

    _controller.logStream.listen((logs) {

      if (mounted) setState(() => _logs = logs);

    });

  }



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  void _applyScroll(double deltaY) {

    if (deltaY.abs() < 0.5) return;

    final applied = deltaY * -0.5;

    setState(() => _scrollOffset += applied);

    _controller.logResponse('Page scroll applied', {

      'deltaY': deltaY.toStringAsFixed(1),

      'applied': applied.toStringAsFixed(1),

      'totalScroll': _scrollOffset.toStringAsFixed(0),

    });

  }



  void _handlePointerMove(PointerMoveEvent e, Size area) {

    _pointerEvents++;

    _lastPointerDelta = e.delta;

    _controller.handlePointer(e.localPosition, area, delta: e.delta);

    _applyScroll(e.delta.dy);

  }



  @override

  Widget build(BuildContext context) {

    final compact = MediaQuery.sizeOf(context).width < 720;



    return Material(

      color: Colors.black.withValues(alpha: 0.94),

      child: Stack(

        fit: StackFit.expand,

        children: [

          SafeArea(

            child: Column(

          children: [

            Padding(

              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),

              child: Row(

                children: [

                  IconButton(

                    onPressed: widget.onClose,

                    icon: const Icon(Icons.close, color: Colors.white),

                  ),

                  const Expanded(

                    child: Text(

                      '✨ Gesture Mode',

                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),

                    ),

                  ),

                  if (_started)

                    TextButton(

                      onPressed: () => setState(() => _showDebug = !_showDebug),

                      child: Text(

                        _showDebug ? 'Hide debug' : 'Show debug',

                        style: const TextStyle(color: Colors.white70, fontSize: 12),

                      ),

                    ),

                  CameraStatusIndicator(state: _state),

                ],

              ),

            ),

            if (!_started)

              Expanded(

                child: Center(

                  child: ConstrainedBox(

                    constraints: const BoxConstraints(maxWidth: 420),

                    child: Padding(

                      padding: const EdgeInsets.all(VStackSpacing.xl),

                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          const Text(

                            'Control the website with your hands',

                            textAlign: TextAlign.center,

                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),

                          ),

                          const SizedBox(height: VStackSpacing.lg),

                          const _InstructionRow(icon: '✋', text: 'Move your hand to scroll'),

                          const _InstructionRow(icon: '☝️', text: 'Point to highlight'),

                          const _InstructionRow(icon: '🤏', text: 'Pinch to zoom'),

                          const _InstructionRow(icon: '↕️', text: 'Swipe to navigate'),

                          const SizedBox(height: VStackSpacing.md),

                          Container(

                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(

                              color: Colors.white.withValues(alpha: 0.06),

                              borderRadius: BorderRadius.circular(10),

                              border: Border.all(color: Colors.white12),

                            ),

                            child: const Text(

                              'Debug panel enabled: you will see camera feed, detections, and live logs on screen while testing.',

                              textAlign: TextAlign.center,

                              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),

                            ),

                          ),

                          const SizedBox(height: VStackSpacing.lg),

                          const Text(

                            'Your camera is used for gesture interaction only. No recording.',

                            textAlign: TextAlign.center,

                            style: TextStyle(color: Colors.white54, fontSize: 12),

                          ),

                          const SizedBox(height: VStackSpacing.lg),

                          FilledButton(

                            onPressed: () {

                              _controller.requestCameraFromUserGesture();

                              setState(() => _started = true);

                            },

                            child: const Text('Start Experience'),

                          ),

                        ],

                      ),

                    ),

                  ),

                ),

              )

            else

              Expanded(

                child: compact

                    ? Column(

                        children: [

                          Expanded(child: _buildInteractionLayer(context)),

                          if (_showDebug)

                            SizedBox(

                              height: 280,

                              child: GestureDebugPanel(

                                state: _state,

                                logs: _logs,

                                scrollOffset: _scrollOffset,

                                lastPointerDelta: _lastPointerDelta,

                                pointerEvents: _pointerEvents,

                                cameraActive: _controller.isCameraActive,

                                cameraMounted: _started && _showDebug,

                                onClearLogs: _controller.clearLogs,

                              ),

                            ),

                        ],

                      )

                    : Row(

                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [

                          Expanded(child: _buildInteractionLayer(context)),

                          if (_showDebug)

                            GestureDebugPanel(

                              state: _state,

                              logs: _logs,

                              scrollOffset: _scrollOffset,

                              lastPointerDelta: _lastPointerDelta,

                              pointerEvents: _pointerEvents,

                              cameraActive: _controller.isCameraActive,

                              cameraMounted: _started && _showDebug,

                              onClearLogs: _controller.clearLogs,

                            ),

                        ],

                      ),

              ),

          ],

            ),

          ),

          if (_started && !_showDebug)

            Offstage(

              child: SizedBox(

                width: 640,

                height: 480,

                child: GestureCameraPreview(

                  mounted: true,

                  streamActive: _controller.isCameraActive,

                ),

              ),

            ),

        ],

      ),

    );

  }



  Widget _buildInteractionLayer(BuildContext context) {

    return Listener(

      behavior: HitTestBehavior.translucent,

      onPointerDown: (e) {

        _pointerEvents++;

        _controller.log(GestureLogCategory.detect, 'Pointer down', {

          'x': e.localPosition.dx.toStringAsFixed(0),

          'y': e.localPosition.dy.toStringAsFixed(0),

        });

      },

      onPointerUp: (e) {

        _controller.log(GestureLogCategory.detect, 'Pointer up', {

          'x': e.localPosition.dx.toStringAsFixed(0),

          'y': e.localPosition.dy.toStringAsFixed(0),

        });

      },

      onPointerMove: (e) {

        final box = context.findRenderObject() as RenderBox?;

        final size = box?.size ?? MediaQuery.sizeOf(context);

        _handlePointerMove(e, size);

      },

      child: GestureDetector(

        onScaleUpdate: (details) {

          if (details.scale != 1.0) {

            _controller.handlePinch(details.scale - 1.0);

          }

        },

        child: Stack(

          clipBehavior: Clip.none,

          children: [

            Transform.scale(

              scale: _state.zoom.clamp(0.85, 1.35),

              child: Transform.translate(

                offset: Offset(0, -_scrollOffset),

                child: widget.child,

              ),

            ),

            Positioned(

              left: (_state.cursorX * MediaQuery.sizeOf(context).width).clamp(0, MediaQuery.sizeOf(context).width - 40),

              top: (_state.cursorY * MediaQuery.sizeOf(context).height * 0.55).clamp(0, MediaQuery.sizeOf(context).height * 0.5),

              child: GestureCursor(

                active: _state.cameraState == GestureCameraState.handDetected ||

                    _state.cameraState == GestureCameraState.ready,

              ),

            ),

            if (_showDebug)

              Positioned(

                top: 8,

                left: 8,

                child: Container(

                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

                  decoration: BoxDecoration(

                    color: Colors.black.withValues(alpha: 0.55),

                    borderRadius: BorderRadius.circular(8),

                    border: Border.all(color: VStackColors.accent.withValues(alpha: 0.4)),

                  ),

                  child: Text(

                    _state.landmarkCount > 0

                        ? '${_state.lastDetection} → ${_state.lastAction} (${_state.landmarkCount} pts)'

                        : '${_state.lastDetection} → ${_state.lastAction}',

                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),

                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

}



class CameraStatusIndicator extends StatelessWidget {

  const CameraStatusIndicator({super.key, required this.state});



  final GestureInteractionState state;



  @override

  Widget build(BuildContext context) {

    final (color, label) = switch (state.cameraState) {

      GestureCameraState.ready => (Colors.green, state.statusMessage),

      GestureCameraState.handDetected => (Colors.green, state.statusMessage),

      GestureCameraState.poorVisibility => (Colors.amber, state.statusMessage),

      GestureCameraState.permissionRequired || GestureCameraState.permissionBlocked => (

          Colors.red,

          state.statusMessage

        ),

      GestureCameraState.searching => (Colors.white70, state.statusMessage),

      GestureCameraState.unsupported => (Colors.grey, state.statusMessage),

      _ => (Colors.white54, state.statusMessage),

    };

    return Flexible(

      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

        decoration: BoxDecoration(

          color: Colors.white.withValues(alpha: 0.08),

          borderRadius: BorderRadius.circular(20),

        ),

        child: Text(

          label,

          maxLines: 2,

          overflow: TextOverflow.ellipsis,

          style: TextStyle(color: color, fontSize: 11),

        ),

      ),

    );

  }

}



class GestureCursor extends StatelessWidget {

  const GestureCursor({super.key, required this.active});

  final bool active;



  @override

  Widget build(BuildContext context) {

    return Container(

      width: 28,

      height: 28,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        color: active ? VStackColors.accent.withValues(alpha: 0.5) : Colors.white24,

        border: Border.all(color: VStackColors.accent, width: 2),

        boxShadow: active

            ? [BoxShadow(color: VStackColors.accent.withValues(alpha: 0.4), blurRadius: 12)]

            : null,

      ),

    );

  }

}



class _InstructionRow extends StatelessWidget {

  const _InstructionRow({required this.icon, required this.text});

  final String icon;

  final String text;



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(

        children: [

          Text(icon, style: const TextStyle(fontSize: 20)),

          const SizedBox(width: 12),

          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),

        ],

      ),

    );

  }

}


