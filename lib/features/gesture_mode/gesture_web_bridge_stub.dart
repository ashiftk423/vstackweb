import 'dart:async';



import 'package:flutter/material.dart';

import 'package:vstackweb/features/gesture_mode/gesture_debug_log.dart';

import 'package:vstackweb/features/gesture_mode/gesture_mode_controller.dart';



GestureWebBridge createGestureWebBridge() => GestureWebBridgeStub();



class GestureWebBridgeStub implements GestureWebBridge {

  final _controller = StreamController<GestureInteractionState>.broadcast();

  final List<GestureDebugEntry> _logs = [];



  @override

  Stream<GestureInteractionState> get stateStream => _controller.stream;



  @override

  List<GestureDebugEntry> get logs => List.unmodifiable(_logs);



  @override

  bool get isCameraActive => false;



  @override

  void addLog(GestureLogCategory category, String message, [Map<String, String> data = const {}]) {

    _logs.add(GestureDebugEntry(time: DateTime.now(), category: category, message: message, data: data));

    if (_logs.length > 80) _logs.removeAt(0);

  }



  @override

  void clearLogs() => _logs.clear();



  @override

  Future<void> initialize() async {

    addLog(GestureLogCategory.system, 'Stub bridge initialized (non-web platform)');

    _controller.add(const GestureInteractionState(

      cameraState: GestureCameraState.unsupported,

      statusMessage: 'Gesture Mode is available on web with camera support.',

      lastAction: 'unsupported',

    ));

  }



  @override

  Future<void> requestCamera() async {}

  @override

  void requestCameraFromUserGesture() {}



  @override

  void onPointerMove(Offset position, Size area, {Offset delta = Offset.zero}) {

    final nx = area.width > 0 ? (position.dx / area.width).clamp(0.0, 1.0) : 0.5;

    final ny = area.height > 0 ? (position.dy / area.height).clamp(0.0, 1.0) : 0.5;

    addLog(GestureLogCategory.detect, 'Pointer move (stub)', {

      'x': nx.toStringAsFixed(2),

      'y': ny.toStringAsFixed(2),

      'dx': delta.dx.toStringAsFixed(1),

      'dy': delta.dy.toStringAsFixed(1),

    });

    _controller.add(GestureInteractionState(

      cameraState: GestureCameraState.handDetected,

      statusMessage: 'Pointer detected (stub — use web + camera)',

      cursorX: nx,

      cursorY: ny,

      lastDetection: 'pointer',

      lastAction: 'move',

      inputSource: 'pointer',

      deltaX: delta.dx,

      deltaY: delta.dy,

    ));

  }



  @override

  void onPinchUpdate(double scaleDelta) {

    addLog(GestureLogCategory.action, 'Pinch (stub)', {'delta': scaleDelta.toStringAsFixed(3)});

  }



  @override

  Future<void> dispose() async => _controller.close();

}

