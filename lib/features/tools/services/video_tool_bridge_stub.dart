abstract class VideoToolBridge {
  Future<void> ensureLoaded();

  /// Compresses video bytes to H.264/AAC MP4. [crf] is 18–40 (lower = higher quality).
  /// [onProgress] receives 0.0–1.0 encode progress when available.
  Future<List<int>> compress(
    List<int> input, {
    required int crf,
    void Function(double progress)? onProgress,
  });
}

VideoToolBridge createVideoToolBridge() => VideoToolBridgeStub();

class VideoToolBridgeStub implements VideoToolBridge {
  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<List<int>> compress(
    List<int> input, {
    required int crf,
    void Function(double progress)? onProgress,
  }) async =>
      throw UnsupportedError('Video compressor requires web');
}
