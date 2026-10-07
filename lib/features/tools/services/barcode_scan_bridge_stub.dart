class BarcodeScanResult {
  const BarcodeScanResult({required this.text, required this.format});

  final String text;
  final String format;
}

abstract class BarcodeScanBridge {
  /// Returns null when no barcode is found in the image.
  Future<BarcodeScanResult?> decodeImage(List<int> bytes, {String mimeType = 'image/png'});

  /// Opens a full-screen camera scanner. Returns null if the user cancels.
  Future<BarcodeScanResult?> scanCamera();
}

BarcodeScanBridge createBarcodeScanBridge() => BarcodeScanBridgeStub();

class BarcodeScanBridgeStub implements BarcodeScanBridge {
  @override
  Future<BarcodeScanResult?> decodeImage(List<int> bytes, {String mimeType = 'image/png'}) async =>
      throw UnsupportedError('Barcode reader requires web');

  @override
  Future<BarcodeScanResult?> scanCamera() async => throw UnsupportedError('Barcode reader requires web');
}
