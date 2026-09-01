abstract class Demo3dBridge {
  Future<void> ensureLoaded();
  void mountViewer(String containerId, String modelUrl);
  void unmountViewer(String containerId);
}

Demo3dBridge createDemo3dBridge() => Demo3dBridgeStub();

class Demo3dBridgeStub implements Demo3dBridge {
  @override
  Future<void> ensureLoaded() async {}

  @override
  void mountViewer(String containerId, String modelUrl) {}

  @override
  void unmountViewer(String containerId) {}
}
