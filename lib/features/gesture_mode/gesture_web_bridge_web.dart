import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:vstackweb/features/gesture_mode/gesture_debug_log.dart';
import 'package:vstackweb/features/gesture_mode/gesture_mode_controller.dart';

GestureWebBridge createGestureWebBridge() => GestureWebBridgeWeb();

class GestureWebBridgeWeb implements GestureWebBridge {
  static const cameraViewType = 'gesture-camera-view';

  static bool _factoryRegistered = false;
  static GestureWebBridgeWeb? _activeBridge;

  final _controller = StreamController<GestureInteractionState>.broadcast();
  final List<GestureDebugEntry> _logs = [];
  html.DivElement? _containerElement;
  StreamSubscription<html.Event>? _handEventSub;
  String? _sessionId;
  double _zoom = 1.0;
  Offset? _lastPointer;
  DateTime? _lastMoveLogAt;
  DateTime? _lastHandLogAt;
  bool _trackerRunning = false;
  bool _bindDispatched = false;
  bool _cameraActive = false;
  bool _pendingCameraStart = false;
  bool _initialized = false;
  bool _usingFallbackContainer = false;
  int _handFrames = 0;

  GestureWebBridgeWeb() {
    _activeBridge = this;
    _registerViewFactoryOnce();
  }

  static void _registerViewFactoryOnce() {
    if (_factoryRegistered) return;
    _factoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(cameraViewType, (
      int viewId,
    ) {
      final bridge = _activeBridge;
      if (bridge == null) {
        return html.DivElement()..id = 'vstack-gesture-empty-$viewId';
      }
      return bridge._buildCameraRoot(viewId);
    });
  }

  GestureInteractionState _current = const GestureInteractionState(
    cameraState: GestureCameraState.initializing,
    statusMessage: 'Initializing...',
  );

  @override
  Stream<GestureInteractionState> get stateStream => _controller.stream;

  @override
  List<GestureDebugEntry> get logs => List.unmodifiable(_logs);

  @override
  bool get isCameraActive => _cameraActive;

  @override
  void addLog(
    GestureLogCategory category,
    String message, [
    Map<String, String> data = const {},
  ]) {
    _logs.add(
      GestureDebugEntry(
        time: DateTime.now(),
        category: category,
        message: message,
        data: data,
      ),
    );
    if (_logs.length > 80) _logs.removeAt(0);
  }

  @override
  void clearLogs() => _logs.clear();

  void _emit(GestureInteractionState s) {
    _current = s;
    if (!_controller.isClosed) _controller.add(s);
  }

  Map<String, dynamic> _parseDetail(dynamic raw) {
    if (raw == null) return {};
    if (raw is String) return jsonDecode(raw) as Map<String, dynamic>;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  double _num(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  bool _bool(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    return fallback;
  }

  String _str(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  int _int(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  void _ensureHandListener() {
    _handEventSub ??= html.window.on['vstack-hand'].listen(_onHandEvent);
  }

  void _onHandEvent(html.Event event) {
    final detail = _parseDetail((event as html.CustomEvent).detail);
    if (detail.isEmpty) return;
    _onHandPayload(detail);
  }

  void _onHandPayload(Map<String, dynamic> detail) {
    final message = _str(detail['message']);

    switch (message) {
      case 'module_loaded':
        addLog(GestureLogCategory.system, 'MediaPipe module loaded');
        _emit(_current.copyWith(modelStatus: 'module_loaded'));
        return;
      case 'model_loading':
        addLog(GestureLogCategory.system, 'MediaPipe model loading...');
        _emit(
          _current.copyWith(
            modelStatus: 'loading',
            statusMessage: 'Loading hand detection model...',
            lastAction: 'model_loading',
          ),
        );
        return;
      case 'model_ready':
        addLog(GestureLogCategory.system, 'MediaPipe model ready', {
          'delegate': _str(detail['delegate'], 'unknown'),
        });
        _emit(
          _current.copyWith(
            modelStatus: 'ready',
            statusMessage: 'Model ready — show your hand',
            lastAction: 'model_ready',
          ),
        );
        return;
      case 'model_error':
        addLog(GestureLogCategory.error, 'MediaPipe model failed', {
          'error': _str(detail['error']),
        });
        _emit(
          _current.copyWith(
            modelStatus: 'error',
            statusMessage: 'Model failed to load',
          ),
        );
        return;
      case 'camera_request':
        addLog(GestureLogCategory.camera, 'Requesting camera (JS)...');
        _emit(
          _current.copyWith(
            cameraState: GestureCameraState.permissionRequired,
            statusMessage: 'Allow camera access...',
          ),
        );
        return;
      case 'camera_granted':
        _cameraActive = true;
        addLog(GestureLogCategory.camera, 'Camera granted', {
          'tracks': _str(detail['tracks']),
          'label': _str(detail['label']),
        });
        _emit(
          _current.copyWith(
            cameraState: GestureCameraState.ready,
            statusMessage: 'Camera live — loading tracker...',
            cameraActive: true,
          ),
        );
        return;
      case 'camera_denied':
        addLog(GestureLogCategory.error, 'Camera denied', {
          'error': _str(detail['error']),
        });
        _emit(
          _current.copyWith(
            cameraState: GestureCameraState.permissionBlocked,
            statusMessage: 'Camera blocked — check browser permissions',
            cameraActive: false,
          ),
        );
        return;
      case 'tracker_started':
        _trackerRunning = true;
        _bindDispatched = true;
        addLog(
          GestureLogCategory.system,
          'MediaPipe tracker loop running (IMAGE mode ~15fps)',
        );
        _emit(
          _current.copyWith(
            cameraState: GestureCameraState.searching,
            modelStatus: 'tracking',
            statusMessage: 'Tracking active — show open palm',
            lastDetection: 'mediapipe_running',
            lastAction: 'track',
            inputSource: 'hand',
            frameCount: 0,
            fps: 0,
          ),
        );
        return;
      case 'tracker_start_failed':
        addLog(GestureLogCategory.error, 'MediaPipe start failed', {
          'error': _str(detail['error']),
        });
        _trackerRunning = false;
        _bindDispatched = false;
        _scheduleBindRetry();
        return;
      case 'container_not_found':
        addLog(GestureLogCategory.error, 'Camera container not found', {
          'containerId': _str(detail['containerId']),
        });
        _bindDispatched = false;
        _pendingCameraStart = true;
        _scheduleBindRetry();
        return;
      case 'detect_error':
        addLog(GestureLogCategory.error, 'MediaPipe detect error', {
          'error': _str(detail['error']),
        });
        return;
      case 'bind_parse_error':
        addLog(GestureLogCategory.error, 'Bind parse error', {
          'error': _str(detail['error']),
        });
        return;
      case 'frame_tick':
        final frame = _int(detail['frame']);
        final fps = _int(detail['fps']);
        final handPresent = _bool(detail['handPresent']);
        _emit(
          _current.copyWith(
            frameCount: frame,
            fps: fps,
            landmarkCount: handPresent ? _current.landmarkCount : 0,
            handLabel: handPresent ? _current.handLabel : '',
            cameraState: handPresent
                ? GestureCameraState.handDetected
                : GestureCameraState.searching,
            lastDetection: handPresent ? _current.lastDetection : 'no_hand',
            cameraActive: true,
            modelStatus: 'tracking',
          ),
        );
        return;
    }

    if (message == 'no_hand_in_frame') {
      final now = DateTime.now();
      if (_lastHandLogAt == null ||
          now.difference(_lastHandLogAt!) >
              const Duration(milliseconds: 1200)) {
        _lastHandLogAt = now;
        addLog(GestureLogCategory.detect, 'No hand in frame');
      }
      _emit(
        _current.copyWith(
          cameraState: GestureCameraState.searching,
          statusMessage: 'Looking for hand...',
          lastDetection: 'no_hand',
          lastAction: 'search',
          inputSource: 'hand',
          landmarkCount: 0,
          handLabel: '',
          deltaX: 0,
          deltaY: 0,
          frameCount: _int(detail['frame']),
          fps: _int(detail['fps']),
          cameraActive: true,
        ),
      );
      return;
    }

    if (message != 'hand_detected') return;

    _handFrames++;
    final x = _num(detail['x'], 0.5);
    final y = _num(detail['y'], 0.5);
    final deltaX = _num(detail['deltaX']);
    final deltaY = _num(detail['deltaY']);
    final pinchDelta = _num(detail['pinchDelta']);
    final handedness = _str(detail['handedness'], 'Unknown');
    final landmarkCount = _int(detail['landmarkCount']);
    final logSample = _bool(detail['logSample']);
    final frame = _int(detail['frame']);
    final fps = _int(detail['fps']);

    if (pinchDelta.abs() > 0.003) {
      _zoom = (_zoom + pinchDelta * 10).clamp(0.8, 1.5);
      addLog(GestureLogCategory.action, 'Hand pinch zoom', {
        'zoom': _zoom.toStringAsFixed(2),
      });
    }

    final moved = deltaY.abs() > 1.5 || deltaX.abs() > 1.5;
    final action = pinchDelta.abs() > 0.003
        ? 'zoom'
        : moved
        ? 'scroll'
        : 'point';

    if (logSample || moved) {
      addLog(
        GestureLogCategory.detect,
        moved ? 'Hand moving' : 'Hand detected',
        {'landmarks': '$landmarkCount', 'fps': '$fps', 'frame': '$frame'},
      );
    }

    _emit(
      _current.copyWith(
        cameraState: GestureCameraState.handDetected,
        statusMessage: moved ? 'Hand moving — scrolling' : 'Hand detected',
        cursorX: x,
        cursorY: y,
        zoom: _zoom,
        isPinching: pinchDelta.abs() > 0.003,
        lastDetection: moved ? 'hand_move' : 'hand_point',
        lastAction: action,
        inputSource: 'hand',
        deltaX: deltaX,
        deltaY: deltaY,
        cameraActive: true,
        modelStatus: 'tracking',
        landmarkCount: landmarkCount,
        handLabel: handedness,
        frameCount: frame,
        fps: fps,
      ),
    );
  }

  void _scheduleBindRetry() {
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (_trackerRunning) return;
      if (_containerElement == null) {
        _ensureFallbackContainer();
      }
      if (_containerElement != null) {
        _bindDispatched = false;
        _bindCameraToJs();
      }
    });
  }

  void _ensureFallbackContainer() {
    if (_containerElement != null) return;

    _sessionId ??= 'gesture-fallback-${DateTime.now().millisecondsSinceEpoch}';
    final containerId = 'vstack-gesture-root-$_sessionId';

    _containerElement = html.DivElement()
      ..id = containerId
      ..style.position = 'fixed'
      ..style.right = '12px'
      ..style.bottom = '12px'
      ..style.width = '320px'
      ..style.height = '140px'
      ..style.zIndex = '999999'
      ..style.backgroundColor = '#000'
      ..style.borderRadius = '8px'
      ..style.overflow = 'hidden';

    html.document.body?.append(_containerElement!);
    _usingFallbackContainer = true;

    addLog(GestureLogCategory.camera, 'Using fallback camera container', {
      'containerId': containerId,
    });

    _onContainerReady();
  }

  void _bindCameraToJs() {
    if (_sessionId == null || _containerElement == null) {
      _pendingCameraStart = true;
      return;
    }
    if (_trackerRunning) return;
    if (_bindDispatched) return;

    _bindDispatched = true;
    _pendingCameraStart = false;
    addLog(GestureLogCategory.system, 'Starting JS camera + MediaPipe', {
      'session': _sessionId!,
    });

    html.window.dispatchEvent(
      html.CustomEvent(
        'vstack-bind-camera',
        detail: jsonEncode({
          'sessionId': _sessionId,
          'containerId': _containerElement!.id,
        }),
      ),
    );
  }

  void _onContainerReady() {
    addLog(GestureLogCategory.camera, 'Camera container mounted in DOM');
    if (_pendingCameraStart || !_trackerRunning) {
      _bindDispatched = false;
      _bindCameraToJs();
    }
  }

  html.DivElement _buildCameraRoot(int viewId) {
    _sessionId = 'gesture-$viewId';
    final containerId = 'vstack-gesture-root-$viewId';

    _containerElement = html.DivElement()
      ..id = containerId
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#000';

    addLog(GestureLogCategory.camera, 'Camera container ready', {
      'viewId': '$viewId',
    });

    scheduleMicrotask(_onContainerReady);

    return _containerElement!;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _ensureHandListener();
    addLog(GestureLogCategory.system, 'Web bridge initializing');

    _emit(
      _current.copyWith(
        cameraState: GestureCameraState.initializing,
        statusMessage: 'Bridge ready — press Start Experience',
      ),
    );
  }

  @override
  void requestCameraFromUserGesture() {
    _ensureHandListener();
    _pendingCameraStart = true;
    addLog(GestureLogCategory.camera, 'Requesting camera (user gesture)…');
    _emit(
      _current.copyWith(
        cameraState: GestureCameraState.permissionRequired,
        statusMessage: 'Allow camera when prompted…',
        lastAction: 'request_camera',
      ),
    );

    if (_containerElement == null) {
      _ensureFallbackContainer();
    }

    _bindDispatched = false;
    _bindCameraToJs();
  }

  @override
  Future<void> requestCamera() async {
    _ensureHandListener();
    _pendingCameraStart = true;
    addLog(GestureLogCategory.camera, 'Requesting camera access…');
    _emit(
      _current.copyWith(
        cameraState: GestureCameraState.permissionRequired,
        statusMessage: 'Allow camera when prompted…',
        lastAction: 'request_camera',
      ),
    );

    if (_containerElement == null) {
      _ensureFallbackContainer();
    }

    _bindCameraToJs();

    if (!_bindDispatched && _containerElement == null) {
      _scheduleBindRetry();
    }
  }

  @override
  void onPointerMove(Offset position, Size area, {Offset delta = Offset.zero}) {
    if (!_cameraActive) return;

    if (_current.inputSource == 'hand' &&
        _current.cameraState == GestureCameraState.handDetected &&
        DateTime.now()
                .difference(
                  _lastHandLogAt ?? DateTime.fromMillisecondsSinceEpoch(0),
                )
                .inMilliseconds <
            400) {
      return;
    }

    final nx = area.width > 0
        ? (position.dx / area.width).clamp(0.0, 1.0)
        : 0.5;
    final ny = area.height > 0
        ? (position.dy / area.height).clamp(0.0, 1.0)
        : 0.5;
    final moved =
        _lastPointer != null && (_lastPointer! - position).distance > 2;

    if (delta.dy.abs() > 0.5) {
      addLog(GestureLogCategory.action, 'Scroll from pointer fallback', {
        'deltaY': delta.dy.toStringAsFixed(1),
      });
    }

    _emit(
      _current.copyWith(
        cameraState: GestureCameraState.handDetected,
        cursorX: nx,
        cursorY: ny,
        lastDetection: moved ? 'pointer_move' : 'pointer_hold',
        lastAction: delta.dy.abs() > 0.5 ? 'scroll' : 'point',
        inputSource: 'pointer',
        deltaX: delta.dx,
        deltaY: delta.dy,
      ),
    );
    _lastPointer = position;
  }

  @override
  void onPinchUpdate(double scaleDelta) {
    _zoom = (_zoom + scaleDelta * 0.02).clamp(0.8, 1.5);
    _emit(
      _current.copyWith(zoom: _zoom, isPinching: true, inputSource: 'pointer'),
    );
  }

  @override
  Future<void> dispose() async {
    if (_sessionId != null) {
      html.window.dispatchEvent(
        html.CustomEvent(
          'vstack-unbind-camera',
          detail: jsonEncode({'sessionId': _sessionId}),
        ),
      );
    }
    await _handEventSub?.cancel();
    _handEventSub = null;
    _cameraActive = false;
    if (_usingFallbackContainer) {
      _containerElement?.remove();
    }
    _containerElement = null;
    _trackerRunning = false;
    _bindDispatched = false;
    _initialized = false;
    if (_activeBridge == this) {
      _activeBridge = null;
    }
    await _controller.close();
  }
}
