import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';

class MicroInteractionsDemo extends StatefulWidget {
  const MicroInteractionsDemo({super.key});

  @override
  State<MicroInteractionsDemo> createState() => _MicroInteractionsDemoState();
}

class _MicroInteractionsDemoState extends State<MicroInteractionsDemo> {
  bool _toggle = true;
  bool _loading = false;
  bool _added = false;
  String? _toast;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DemoThemes.motion(),
      child: DemoDeviceFrame(
        type: DemoFrameType.plain,
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('UI Motion Patterns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Real interaction patterns used in production apps.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Add to Cart feedback',
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _added
                          ? Container(
                              key: const ValueKey('added'),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, color: Color(0xFF166534), size: 18), SizedBox(width: 8), Text('Added to cart', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600))]),
                            )
                          : FilledButton.icon(
                              key: const ValueKey('btn'),
                              onPressed: () => setState(() => _added = true),
                              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                              label: const Text('Add to Cart'),
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFB641B)),
                            ),
                    ),
                  ),
                  _Section(
                    title: 'Toggle with spring',
                    child: Row(
                      children: [
                        Switch(value: _toggle, onChanged: (v) => setState(() => _toggle = v), activeColor: const Color(0xFF3B82F6)),
                        const SizedBox(width: 12),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(fontWeight: FontWeight.w600, color: _toggle ? const Color(0xFF3B82F6) : Colors.grey),
                          child: Text(_toggle ? 'Notifications ON' : 'Notifications OFF'),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Skeleton loading',
                    child: _loading
                        ? Column(
                            children: List.generate(2, (i) => Container(
                              height: 56,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.shade200)),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() => _loading = true);
                              await Future<void>.delayed(const Duration(seconds: 1));
                              if (mounted) setState(() => _loading = false);
                            },
                            child: const Text('Simulate load'),
                          ),
                  ),
                  _Section(
                    title: 'Toast notification',
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _toast = 'Payment successful!');
                        Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _toast = null); });
                      },
                      child: const Text('Show toast'),
                    ),
                  ),
                ],
              ),
              if (_toast != null)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF1E293B),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 20), const SizedBox(width: 10), Text(_toast!, style: const TextStyle(color: Colors.white))]),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.3, end: 0, duration: 250.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
