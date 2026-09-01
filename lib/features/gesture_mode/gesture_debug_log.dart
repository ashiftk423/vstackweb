import 'package:flutter/foundation.dart';

enum GestureLogCategory { camera, detect, action, response, error, system }

@immutable
class GestureDebugEntry {
  const GestureDebugEntry({
    required this.time,
    required this.category,
    required this.message,
    this.data = const {},
  });

  final DateTime time;
  final GestureLogCategory category;
  final String message;
  final Map<String, String> data;

  String get timeLabel {
    final t = time;
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}.'
        '${(t.millisecond ~/ 100).toString()}';
  }
}
