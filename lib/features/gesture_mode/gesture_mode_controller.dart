import 'package:flutter/material.dart';
import 'package:vstackweb/features/gesture_mode/gesture_debug_log.dart';

enum GestureCameraState {
  initializing,
  ready,
  searching,
  handDetected,
  poorVisibility,
  permissionRequired,
  permissionBlocked,
  unsupported,
}

class GestureInteractionState {
  const GestureInteractionState({
    required this.cameraState,
    this.statusMessage = '',
    this.cursorX = 0.5,
    this.cursorY = 0.5,
    this.zoom = 1.0,
    this.isPinching = false,
    this.lastAction = 'idle',
    this.lastDetection = 'none',
    this.inputSource = 'none',
    this.deltaX = 0,
    this.deltaY = 0,
    this.cameraActive = false,
    this.modelStatus = 'idle',
    this.landmarkCount = 0,
    this.handLabel = '',
    this.frameCount = 0,
    this.fps = 0,
  });

  final GestureCameraState cameraState;
  final String statusMessage;
  final double cursorX;
  final double cursorY;
  final double zoom;
  final bool isPinching;
  final String lastAction;
  final String lastDetection;
  final String inputSource;
  final double deltaX;
  final double deltaY;
  final bool cameraActive;
  final String modelStatus;
  final int landmarkCount;
  final String handLabel;
  final int frameCount;
  final int fps;

  GestureInteractionState copyWith({
    GestureCameraState? cameraState,
    String? statusMessage,
    double? cursorX,
    double? cursorY,
    double? zoom,
    bool? isPinching,
    String? lastAction,
    String? lastDetection,
    String? inputSource,
    double? deltaX,
    double? deltaY,
    bool? cameraActive,
    String? modelStatus,
    int? landmarkCount,
    String? handLabel,
    int? frameCount,
    int? fps,
  }) =>
      GestureInteractionState(
        cameraState: cameraState ?? this.cameraState,
        statusMessage: statusMessage ?? this.statusMessage,
        cursorX: cursorX ?? this.cursorX,
        cursorY: cursorY ?? this.cursorY,
        zoom: zoom ?? this.zoom,
        isPinching: isPinching ?? this.isPinching,
        lastAction: lastAction ?? this.lastAction,
        lastDetection: lastDetection ?? this.lastDetection,
        inputSource: inputSource ?? this.inputSource,
        deltaX: deltaX ?? this.deltaX,
        deltaY: deltaY ?? this.deltaY,
        cameraActive: cameraActive ?? this.cameraActive,
        modelStatus: modelStatus ?? this.modelStatus,
        landmarkCount: landmarkCount ?? this.landmarkCount,
        handLabel: handLabel ?? this.handLabel,
        frameCount: frameCount ?? this.frameCount,
        fps: fps ?? this.fps,
      );
}

abstract class GestureWebBridge {
  Future<void> initialize();
  Future<void> dispose();
  Stream<GestureInteractionState> get stateStream;
  void onPointerMove(Offset position, Size area, {Offset delta = Offset.zero});
  void onPinchUpdate(double scaleDelta);
  Future<void> requestCamera();
  void requestCameraFromUserGesture();
  void addLog(GestureLogCategory category, String message, [Map<String, String> data = const {}]);
  List<GestureDebugEntry> get logs;
  void clearLogs();
  bool get isCameraActive;
}
