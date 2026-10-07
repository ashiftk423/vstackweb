export 'barcode_scan_bridge_stub.dart' show BarcodeScanBridge, BarcodeScanResult;
export 'barcode_scan_bridge_stub.dart'
    if (dart.library.html) 'barcode_scan_bridge_web.dart' show createBarcodeScanBridge;
