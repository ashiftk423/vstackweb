import 'dart:math' as math;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/barcode_view.dart';

enum IdCardSide { front, back }

/// Landscape CR80 ID card (85.6 × 54 mm), drawn on a fixed 856 × 540 canvas and
/// scaled to fit, so the layout is identical on screen and in PNG exports.
class EmployeeIdCard extends StatelessWidget {
  const EmployeeIdCard({
    super.key,
    required this.member,
    required this.contact,
    this.side = IdCardSide.front,
    this.boundaryKey,
  });

  static const designSize = Size(856, 540);

  final TeamMember member;
  final ContactInfo contact;
  final IdCardSide side;

  /// When set, the card canvas is wrapped in a RepaintBoundary for PNG export.
  final GlobalKey? boundaryKey;

  @override
  Widget build(BuildContext context) {
    Widget face = SizedBox.fromSize(
      size: designSize,
      child: side == IdCardSide.front
          ? _CardFront(member: member)
          : _CardBack(member: member, contact: contact),
    );
    if (boundaryKey != null) face = RepaintBoundary(key: boundaryKey, child: face);
    return AspectRatio(
      aspectRatio: designSize.width / designSize.height,
      child: FittedBox(child: face),
    );
  }
}

/// Tap to flip between the front and back of an [EmployeeIdCard].
class FlippableIdCard extends StatefulWidget {
  const FlippableIdCard({super.key, required this.member, required this.contact});

  final TeamMember member;
  final ContactInfo contact;

  @override
  State<FlippableIdCard> createState() => _FlippableIdCardState();
}

class _FlippableIdCardState extends State<FlippableIdCard> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final _angle = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    final showingBack = _controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.completed;
    showingBack ? _controller.reverse() : _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _angle,
          builder: (context, _) {
            final angle = _angle.value * math.pi;
            final showBack = angle > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: EmployeeIdCard(
                        member: widget.member,
                        contact: widget.contact,
                        side: IdCardSide.back,
                      ),
                    )
                  : EmployeeIdCard(member: widget.member, contact: widget.contact),
            );
          },
        ),
      ),
    );
  }
}

const _cardRadius = 36.0;
const _ink = Color(0xFF0A0F1D);

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cardRadius),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1224), Color(0xFF070A14), Color(0xFF120B26)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -140,
              top: -160,
              child: _Glow(color: VStackColors.accent.withValues(alpha: 0.32), size: 460),
            ),
            Positioned(
              left: -160,
              bottom: -200,
              child: _Glow(color: VStackColors.accent2.withValues(alpha: 0.28), size: 480),
            ),
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [VStackColors.accent, VStackColors.accent2]),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_cardRadius),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 2),
                ),
              ),
            ),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logo = compact ? 44.0 : 58.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logo,
          height: logo,
          padding: EdgeInsets.all(logo * 0.12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(logo * 0.28),
          ),
          child: Image.asset('assets/logo/v_stack_logo-removebg-preview.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VStack',
              style: TextStyle(fontSize: compact ? 24 : 30, fontWeight: FontWeight.w800, height: 1.05),
            ),
            Text(
              'Business Solutions',
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                color: VStackColors.muted,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IdPill extends StatelessWidget {
  const _IdPill({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: VStackColors.accent.withValues(alpha: 0.12),
        border: Border.all(color: VStackColors.accent.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Text(
        id,
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final photo = member.photo;
    final Widget inner = photo == null || photo.isEmpty
        ? Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16233F), Color(0xFF1C1240)],
              ),
            ),
            child: Text(
              member.initials,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
          )
        : (photo.startsWith('http')
            ? Image.network(photo, fit: BoxFit.cover)
            : Image.asset(photo, fit: BoxFit.cover));
    return Container(
      width: 184,
      height: 184,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [VStackColors.accent, VStackColors.accent2, VStackColors.accent],
        ),
        boxShadow: [
          BoxShadow(color: VStackColors.accent.withValues(alpha: 0.35), blurRadius: 30),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _ink),
        child: ClipOval(child: SizedBox.expand(child: inner)),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(44, 38, 44, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _Brand(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: const Text(
                    'EMPLOYEE ID CARD',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(member: member),
                const SizedBox(width: 34),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member.displayCardName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, height: 1.1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        member.role,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xFFB79CFF),
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (member.department != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Department · ${member.department}',
                          style: const TextStyle(fontSize: 16, color: VStackColors.muted),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _IdPill(id: member.employeeId),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: BarcodeView(
                        barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium),
                        data: member.cardUrl,
                        width: 138,
                        height: 138,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SCAN TO VERIFY',
                      style: TextStyle(fontSize: 12, color: VStackColors.muted, letterSpacing: 2),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const Row(
              children: [
                Text('vstackbusinesssolutions.com', style: TextStyle(fontSize: 15, color: VStackColors.muted)),
                Spacer(),
                Text(
                  'We Stack Your Business',
                  style: TextStyle(fontSize: 15, color: VStackColors.accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.member, required this.contact});

  final TeamMember member;
  final ContactInfo contact;

  @override
  Widget build(BuildContext context) {
    final details = <(String, String)>[
      if (member.joinedOn != null) ('JOINED', member.joinedOn!),
      if (member.validUntil != null) ('VALID UNTIL', member.validUntil!),
      if (member.bloodGroup != null) ('BLOOD GROUP', member.bloodGroup!),
      if (member.phone != null) ('PHONE', member.phone!),
      if (member.email != null) ('EMAIL', member.email!),
    ];
    if (details.isEmpty) {
      details.addAll([
        ('DEPARTMENT', member.department ?? 'VStack'),
        ('OFFICE', contact.phoneDisplay ?? contact.whatsappNumber),
        ('EMAIL', contact.email),
      ]);
    }
    final phone = contact.phoneDisplay ?? contact.whatsappNumber;

    return _CardSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(44, 36, 44, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const _Brand(compact: true),
                const Spacer(),
                Text(
                  member.employeeId,
                  style: const TextStyle(fontSize: 18, color: VStackColors.muted, letterSpacing: 2),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                for (final (i, d) in details.take(3).indexed) ...[
                  if (i > 0) const SizedBox(width: 18),
                  Expanded(child: _DetailTile(label: d.$1, value: d.$2)),
                ],
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, c) => BarcodeView(
                      barcode: Barcode.code128(),
                      data: member.cardUrl,
                      width: c.maxWidth,
                      height: 104,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.employeeId,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This card is the property of VStack Business Solutions. If found, please return it or call $phone.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: VStackColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: VStackColors.muted, letterSpacing: 1.6)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
