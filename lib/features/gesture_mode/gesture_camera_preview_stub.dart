import 'package:flutter/material.dart';

class GestureCameraPreview extends StatelessWidget {
  const GestureCameraPreview({
    super.key,
    required this.mounted,
    this.streamActive = false,
  });

  final bool mounted;
  final bool streamActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Text(
        mounted ? 'Camera preview (web only)' : 'Press Start Experience',
        style: const TextStyle(color: Colors.white54, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}
