import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:vstackweb/features/tools/services/file_download.dart';

abstract final class ImageToolService {
  static const maxFileBytes = 15 * 1024 * 1024;

  static img.Image? decodeBytes(List<int> bytes) {
    if (bytes.length > maxFileBytes) return null;
    return img.decodeImage(Uint8List.fromList(bytes));
  }

  static List<int>? compressJpeg(img.Image image, {int quality = 85}) {
    return img.encodeJpg(image, quality: quality.clamp(1, 100));
  }

  static List<int>? compressPng(img.Image image, {int level = 6}) {
    return img.encodePng(image, level: level.clamp(0, 9));
  }

  static List<int>? encodeWebp(img.Image image, {int quality = 85}) {
    // image 4.x supports WebP decode only; export as JPEG for compatibility.
    return img.encodeJpg(image, quality: quality.clamp(1, 100));
  }

  static img.Image resize(
    img.Image image, {
    required int width,
    required int height,
    bool maintainAspect = true,
  }) {
    if (maintainAspect) {
      return img.copyResize(image, width: width, height: height, maintainAspect: true);
    }
    return img.copyResize(image, width: width, height: height);
  }

  static String formatLabel(String ext) => ext.toUpperCase();

  static String mimeForExt(String ext) => switch (ext.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'pdf' => 'application/pdf',
        _ => 'application/octet-stream',
      };

  static void download(List<int> bytes, String filename, {String? mimeType}) {
    downloadBytes(bytes, filename, mimeType: mimeType);
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static int savingsPercent(int original, int compressed) {
    if (original <= 0) return 0;
    return ((1 - compressed / original) * 100).round().clamp(0, 100);
  }
}
