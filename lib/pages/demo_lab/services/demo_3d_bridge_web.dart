import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:vstackweb/pages/demo_lab/services/demo_3d_bridge_stub.dart';

Demo3dBridge createDemo3dBridge() => Demo3dBridgeWeb();

class Demo3dBridgeWeb implements Demo3dBridge {
  bool _loaded = false;

  @override
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (html.document.querySelector('script[data-vstack-3d]') != null) {
      await _waitReady();
      return;
    }
    final script = html.ScriptElement()
      ..dataset['vstack3d'] = 'true'
      ..type = 'module'
      ..src = 'demo_3d_viewer.js';
    html.document.head!.append(script);
    await _waitReady();
  }

  Future<void> _waitReady() async {
    for (var i = 0; i < 50; i++) {
      if ((html.window as dynamic).VStack3d?.isReady == true) {
        _loaded = true;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw StateError('3D viewer failed to load');
  }

  @override
  void mountViewer(String containerId, String modelUrl) {
    ui_web.platformViewRegistry.registerViewFactory(containerId, (viewId) {
      final div = html.DivElement()
        ..id = containerId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#0A1020';
      Future.microtask(() async {
        try {
          await ensureLoaded();
          (html.window as dynamic).VStack3d.mount(containerId, modelUrl);
        } catch (_) {
          div.text = '3D preview unavailable on this device.';
        }
      });
      return div;
    });
  }

  @override
  void unmountViewer(String containerId) {
    try {
      (html.window as dynamic).VStack3d?.unmount(containerId);
    } catch (_) {}
  }
}
