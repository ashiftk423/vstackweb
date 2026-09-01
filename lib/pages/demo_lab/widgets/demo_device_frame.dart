import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

enum DemoFrameType { browser, desktop, phone, plain }

class DemoDeviceFrame extends StatelessWidget {
  const DemoDeviceFrame({
    super.key,
    required this.type,
    required this.child,
    this.title = 'VSTACK Showcase',
  });

  final DemoFrameType type;
  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      DemoFrameType.browser => _BrowserFrame(title: title, child: child),
      DemoFrameType.desktop => _DesktopFrame(title: title, child: child),
      DemoFrameType.phone => _PhoneFrame(child: child),
      DemoFrameType.plain => child,
    };
  }
}

class _BrowserFrame extends StatelessWidget {
  const _BrowserFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VStackColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: VStackColors.surface,
            child: Row(
              children: [
                Row(
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: [const Color(0xFFFF5F57), const Color(0xFFFFBD2E), const Color(0xFF28CA41)][i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: VStackColors.bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'vstack-demo.com/$title',
                      style: const TextStyle(color: VStackColors.muted, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopFrame extends StatelessWidget {
  const _DesktopFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12182A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: VStackColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF1A2238),
            child: Row(
              children: [
                const Icon(Icons.desktop_windows, size: 14, color: VStackColors.muted),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.minimize, size: 14, color: VStackColors.muted),
                const SizedBox(width: 8),
                const Icon(Icons.crop_square, size: 14, color: VStackColors.muted),
                const SizedBox(width: 8),
                const Icon(Icons.close, size: 14, color: VStackColors.muted),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 640,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: VStackColors.border, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 28,
              color: Colors.black,
              alignment: Alignment.center,
              child: Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: VStackColors.surfaceLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Expanded(child: child),
            Container(height: 20, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
