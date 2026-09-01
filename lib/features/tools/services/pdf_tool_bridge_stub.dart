abstract class PdfToolBridge {
  Future<void> ensureLoaded();
  Future<List<int>> mergePdfs(List<List<int>> files);
  Future<List<List<int>>> splitPdf(List<int> file);
  Future<List<int>> imagesToPdf(List<List<int>> images);
}

PdfToolBridge createPdfToolBridge() => PdfToolBridgeStub();

class PdfToolBridgeStub implements PdfToolBridge {
  @override
  Future<void> ensureLoaded() async {}

  @override
  Future<List<int>> mergePdfs(List<List<int>> files) async => throw UnsupportedError('PDF tools require web');

  @override
  Future<List<List<int>>> splitPdf(List<int> file) async => throw UnsupportedError('PDF tools require web');

  @override
  Future<List<int>> imagesToPdf(List<List<int>> images) async => throw UnsupportedError('PDF tools require web');
}
