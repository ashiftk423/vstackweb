import 'package:flutter/material.dart';
import 'package:vstackweb/models/demo.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class DemoComingSoon extends StatelessWidget {
  const DemoComingSoon({super.key, required this.demo});

  final DemoEntry demo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_outlined, size: 48, color: VStackColors.muted),
          const SizedBox(height: 16),
          Text('${demo.title} — coming soon', style: const TextStyle(color: VStackColors.muted)),
        ],
      ),
    );
  }
}
