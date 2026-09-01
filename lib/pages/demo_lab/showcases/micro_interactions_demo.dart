import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class MicroInteractionsDemo extends StatefulWidget {
  const MicroInteractionsDemo({super.key});

  @override
  State<MicroInteractionsDemo> createState() => _MicroInteractionsDemoState();
}

class _MicroInteractionsDemoState extends State<MicroInteractionsDemo> {
  bool _toggle = false;
  bool _loading = false;
  String? _toast;

  void _showToast(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _simulateLoad() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      _showToast('Action completed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.plain,
      child: Container(
        color: VStackColors.bg,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Micro-interactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(onPressed: _simulateLoad, child: const Text('Ripple Button')),
                    OutlinedButton(onPressed: () => _showToast('Secondary action'), child: const Text('Outline')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Switch(
                      value: _toggle,
                      onChanged: (v) => setState(() => _toggle = v),
                    ),
                    const SizedBox(width: 8),
                    Text('Spring toggle: ${_toggle ? 'ON' : 'OFF'}'),
                  ],
                ),
                const SizedBox(height: 24),
                if (_loading)
                  Column(
                    children: List.generate(
                      3,
                      (i) => Container(
                        height: 48,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: VStackColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 1200.ms, color: VStackColors.accent.withValues(alpha: 0.15)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: VStackColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VStackColors.border),
                    ),
                    child: const Text('Content loaded. Tap the button above to see skeleton loaders.'),
                  ),
              ],
            ),
            if (_toast != null)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Material(
                  color: VStackColors.accent,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(_toast!, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.5, end: 0),
              ),
          ],
        ),
      ),
    );
  }
}
