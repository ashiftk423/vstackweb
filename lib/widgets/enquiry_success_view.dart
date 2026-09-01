import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

/// Google Pay–style success animation shown after an enquiry is sent.
class EnquirySuccessView extends StatefulWidget {
  const EnquirySuccessView({
    super.key,
    required this.channel,
    required this.onNewEnquiry,
    this.title = 'Enquiry sent!',
    this.subtitle,
  });

  final String channel;
  final VoidCallback onNewEnquiry;
  final String title;
  final String? subtitle;

  @override
  State<EnquirySuccessView> createState() => _EnquirySuccessViewState();
}

class _EnquirySuccessViewState extends State<EnquirySuccessView>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _pulse;
  late final Animation<double> _ringExpand;
  late final Animation<double> _ringFade;
  late final Animation<double> _coreScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  static const _successGreen = Color(0xFF34C759);

  @override
  void initState() {
    super.initState();
    _main = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _ringExpand = Tween<double>(begin: 0.35, end: 1.35).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)),
    );
    _ringFade = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.25, 0.75, curve: Curves.easeOut)),
    );
    _coreScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.15, 0.55, curve: Curves.elasticOut)),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.42, 0.78, curve: Curves.elasticOut)),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.58, 0.95, curve: Curves.easeOut)),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _main, curve: const Interval(0.58, 0.95, curve: Curves.easeOutCubic)),
    );

    _main.forward();
  }

  @override
  void dispose() {
    _main.dispose();
    _pulse.dispose();
    super.dispose();
  }

  String get _channelLabel =>
      widget.channel == 'whatsapp' ? 'WhatsApp' : 'Email';

  String get _defaultSubtitle =>
      'Your enquiry draft was opened in $_channelLabel. '
      'Tap send there to complete — we\'ll get back to you soon.';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_main, _pulse]),
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _RippleRing(
                      progress: _ringExpand.value,
                      opacity: _ringFade.value * 0.45,
                      color: _successGreen,
                    ),
                    _RippleRing(
                      progress: _ringExpand.value * 0.82,
                      opacity: _ringFade.value * 0.25,
                      color: VStackColors.accent,
                    ),
                    Transform.scale(
                      scale: 1.0 + (math.sin(_pulse.value * math.pi * 2) * 0.015 * _main.value),
                      child: Transform.scale(
                        scale: _coreScale.value,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4CD964), _successGreen],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _successGreen.withValues(alpha: 0.45),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Transform.scale(
                            scale: _checkScale.value,
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(8, (i) {
                      final angle = (i / 8) * math.pi * 2;
                      final dist = 52 + (_main.value * 18);
                      final dotOpacity = (1 - _main.value).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(math.cos(angle) * dist, math.sin(angle) * dist),
                        child: Opacity(
                          opacity: dotOpacity * 0.8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i.isEven ? _successGreen : VStackColors.accent,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subtitle ?? _defaultSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: VStackColors.muted.withValues(alpha: 0.95),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: widget.onNewEnquiry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Send a new enquiry'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RippleRing extends StatelessWidget {
  const _RippleRing({
    required this.progress,
    required this.opacity,
    required this.color,
  });

  final double progress;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: 120 * progress,
        height: 120 * progress,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
      ),
    );
  }
}
