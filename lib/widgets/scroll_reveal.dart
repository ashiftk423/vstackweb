import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Replays fade/slide whenever the widget enters the viewport (scroll down or up).
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.id,
    this.delay = Duration.zero,
    this.offsetY = 40,
    this.slideFromLeft = false,
    this.visibleThreshold = 0.12,
    this.hiddenThreshold = 0.04,
  });

  final Widget child;
  final String? id;
  final Duration delay;
  final double offsetY;
  final bool slideFromLeft;
  final double visibleThreshold;
  final double hiddenThreshold;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _visible = false;
  int _delayToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = Tween<double>(begin: 0, end: 1).animate(curve);
    final dx = widget.slideFromLeft ? -0.06 : 0.0;
    _slide = Tween<Offset>(
      begin: Offset(dx, widget.offsetY / 500),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisible(VisibilityInfo info) {
    if (!mounted) return;

    if (info.visibleFraction >= widget.visibleThreshold) {
      if (_visible) return;
      _visible = true;
      final token = ++_delayToken;
      Future<void>.delayed(widget.delay, () {
        if (!mounted || token != _delayToken || !_visible) return;
        _controller.forward(from: 0);
      });
    } else if (info.visibleFraction <= widget.hiddenThreshold) {
      if (!_visible) return;
      _visible = false;
      _delayToken++;
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.id ?? 'reveal-${widget.hashCode}'),
      onVisibilityChanged: _onVisible,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
