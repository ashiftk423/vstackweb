import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';

/// Paints any [Barcode] type (Code 128, EAN, QR, Data Matrix, …) at the given size.
class BarcodeView extends StatelessWidget {
  const BarcodeView({
    super.key,
    required this.barcode,
    required this.data,
    required this.width,
    required this.height,
    this.color = Colors.black,
  });

  final Barcode barcode;
  final String data;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: BarcodePainter(barcode: barcode, data: data, color: color),
    );
  }
}

class BarcodePainter extends CustomPainter {
  BarcodePainter({required this.barcode, required this.data, required this.color});

  final Barcode barcode;
  final String data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Anti-aliasing leaves hairline seams between adjacent modules.
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    try {
      for (final e in barcode.make(data, width: size.width, height: size.height)) {
        if (e is BarcodeBar && e.black) {
          canvas.drawRect(Rect.fromLTWH(e.left, e.top, e.width, e.height), paint);
        }
      }
    } on BarcodeException {
      // Invalid data for this symbology; callers validate and show the error.
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter old) =>
      old.data != data || old.color != color || old.barcode.name != barcode.name;
}
