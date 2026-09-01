import 'dart:async';



import 'package:flutter/material.dart';

import 'package:vstackweb/features/gesture_mode/gesture_debug_log.dart';

import 'package:vstackweb/features/gesture_mode/gesture_mode_controller.dart';

import 'package:vstackweb/features/gesture_mode/gesture_web_bridge_stub.dart'

    if (dart.library.html) 'package:vstackweb/features/gesture_mode/gesture_web_bridge_web.dart';



class GestureModeController {

  GestureModeController() : _bridge = createGestureWebBridge();



  final GestureWebBridge _bridge;

  final _controller = StreamController<GestureInteractionState>.broadcast();

  final _logController = StreamController<List<GestureDebugEntry>>.broadcast();



  Stream<GestureInteractionState> get states => _controller.stream;

  Stream<List<GestureDebugEntry>> get logStream => _logController.stream;

  List<GestureDebugEntry> get logs => _bridge.logs;

  bool get isCameraActive => _bridge.isCameraActive;



  GestureInteractionState _state = const GestureInteractionState(

    cameraState: GestureCameraState.initializing,

    statusMessage: 'Starting camera...',

  );



  bool _prepared = false;

  Future<void> prepare() async {
    if (_prepared) return;
    _prepared = true;
    await _bridge.initialize();
    _bridge.stateStream.listen(_onBridgeState);
  }

  /// Must run synchronously inside the Start button [onPressed] so Chrome
  /// keeps the user-gesture token for getUserMedia.
  void requestCameraFromUserGesture() {
    _bridge.requestCameraFromUserGesture();
    log(GestureLogCategory.system, 'Gesture mode started');
    _emit(_state.copyWith(
      cameraState: GestureCameraState.initializing,
      statusMessage: 'Starting camera...',
      lastAction: 'init',
    ));
  }

  Future<void> start() async {
    await prepare();
    await _bridge.requestCamera();
  }



  void handlePointer(Offset pos, Size size, {Offset delta = Offset.zero}) {

    _bridge.onPointerMove(pos, size, delta: delta);

  }



  void handlePinch(double delta) {

    log(GestureLogCategory.action, 'Pinch gesture', {'delta': delta.toStringAsFixed(3)});

    _bridge.onPinchUpdate(delta);

  }



  void logResponse(String action, Map<String, String> data) {

    log(GestureLogCategory.response, action, data);

    _emit(_state.copyWith(lastAction: action));

  }



  void log(GestureLogCategory category, String message, [Map<String, String> data = const {}]) {

    _bridge.addLog(category, message, data);

    if (!_logController.isClosed) _logController.add(_bridge.logs);

  }



  void clearLogs() {

    _bridge.clearLogs();

    if (!_logController.isClosed) _logController.add(_bridge.logs);

  }



  void _onBridgeState(GestureInteractionState s) {

    _emit(s);

    if (!_logController.isClosed) _logController.add(_bridge.logs);

  }



  void _emit(GestureInteractionState s) {

    _state = s;

    if (!_controller.isClosed) _controller.add(s);

  }



  Future<void> dispose() async {

    log(GestureLogCategory.system, 'Gesture mode disposed');

    await _bridge.dispose();

    await _controller.close();

    await _logController.close();

  }

}

