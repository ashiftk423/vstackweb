import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vstackweb/constants/brand_assets.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/barcode_view.dart';

enum IdCardSide { front, back }

/// Portrait CR80 ID card (54 × 85.6 mm), drawn on a fixed 540 × 856 canvas and
/// scaled to fit, so the layout is identical on screen and in PNG exports.
///
/// Employee photos should be background-removed PNGs; they are shown large with
/// a faded oversized copy behind them.
class EmployeeIdCard extends StatelessWidget {
  const EmployeeIdCard({
    super.key,
    required this.member,
    required this.contact,
    this.side = IdCardSide.front,
    this.boundaryKey,
  });

  static const designSize = Size(540, 856);

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
    if (boundaryKey != null) {
      face = RepaintBoundary(key: boundaryKey, child: face);
    }
    return AspectRatio(
      aspectRatio: designSize.width / designSize.height,
      child: FittedBox(child: face),
    );
  }
}

/// Tap to flip between the front and back of an [EmployeeIdCard].
class FlippableIdCard extends StatefulWidget {
  const FlippableIdCard({
    super.key,
    required this.member,
    required this.contact,
  });

  final TeamMember member;
  final ContactInfo contact;

  @override
  State<FlippableIdCard> createState() => _FlippableIdCardState();
}

class _FlippableIdCardState extends State<FlippableIdCard>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final _angle = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    final showingBack =
        _controller.status == AnimationStatus.forward ||
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
                  : EmployeeIdCard(
                      member: widget.member,
                      contact: widget.contact,
                    ),
            );
          },
        ),
      ),
    );
  }
}

const _cardRadius = 30.0;
const _ink = Color(0xFF0A0F1D);
const _bgTop = Color(0xFF060A14);
const _bgBottom = Color(0xFF03050B);
const _beamBlue = Color(0xFF1E6BFF);
const _roleBlue = Color(0xFF2F8BFF);

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, Color(0xFF070B18), _bgBottom],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _LightBeamsPainter())),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_beamBlue, VStackColors.accent2],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(child: child),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_cardRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diagonal blue light streaks along the right edge.
class _LightBeamsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void beam(List<Offset> pts, double alpha, {double glow = 0}) {
      final path = Path()..addPolygon(pts, true);
      final bounds = path.getBounds();
      final shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _beamBlue.withValues(alpha: alpha * 0.25),
          _beamBlue.withValues(alpha: alpha),
          const Color(0xFF0B2A7A).withValues(alpha: alpha * 0.6),
        ],
        stops: const [0, 0.55, 1],
      ).createShader(bounds);
      if (glow > 0) {
        canvas.drawPath(
          path,
          Paint()
            ..color = _beamBlue.withValues(alpha: alpha * 0.55)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow),
        );
      }
      canvas.drawPath(path, Paint()..shader = shader);
    }

    // Dark wedge that the light streaks sit on.
    beam([
      Offset(w * 0.52, 0),
      Offset(w * 0.86, 0),
      Offset(w, h * 0.30),
      Offset(w, h * 0.62),
    ], 0.10);
    beam(
      [
        Offset(w * 0.70, 0),
        Offset(w * 0.80, 0),
        Offset(w, h * 0.33),
        Offset(w, h * 0.45),
      ],
      0.55,
      glow: 26,
    );
    beam(
      [
        Offset(w * 0.88, 0),
        Offset(w * 0.905, 0),
        Offset(w, h * 0.155),
        Offset(w, h * 0.19),
      ],
      0.9,
      glow: 10,
    );
    beam(
      [
        Offset(w * 0.60, h * 0.02),
        Offset(w * 0.615, h * 0.02),
        Offset(w, h * 0.66),
        Offset(w, h * 0.69),
      ],
      0.85,
      glow: 14,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Brand extends StatelessWidget {
  const _Brand({this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          BrandAssets.logoWhite,
          width: 86 * scale,
          height: 86 * scale,
        ),
        SizedBox(width: 16 * scale),
        Container(
          width: 2.5,
          height: 70 * scale,
          color: Colors.white.withValues(alpha: 0.85),
        ),
        SizedBox(width: 16 * scale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VSTACK',
              style: TextStyle(
                fontSize: 54 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.5 * scale,
                height: 1,
              ),
            ),
            SizedBox(height: 5 * scale),
            Text(
              'BUSINESS SOLUTIONS',
              style: TextStyle(
                fontSize: 17 * scale,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.6 * scale,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

ImageProvider _photoProvider(String photo) => photo.startsWith('http')
    ? NetworkImage(photo)
    : AssetImage(photo) as ImageProvider;

/// Big cut-out photo with an oversized faded copy behind it, as in the
/// VStack poster style. Falls back to large initials when there is no photo.
class _HeroPortrait extends StatelessWidget {
  const _HeroPortrait({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final photo = member.photo;
    if (photo == null || photo.isEmpty) {
      return _InitialsPortrait(initials: member.initials);
    }
    final image = _photoProvider(photo);

    Widget fadedBottom(Widget child) => ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.8, 1],
      ).createShader(rect),
      child: child,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Oversized faded copy, offset left.
        Positioned(
          left: -190,
          top: 40,
          width: 560,
          height: 700,
          child: Opacity(
            opacity: 0.22,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.35, 0.35, 0.35, 0, 0, //
                0.35, 0.35, 0.35, 0, 0,
                0.40, 0.40, 0.40, 0, 6,
                0, 0, 0, 1, 0,
              ]),
              child: fadedBottom(
                Image(
                  image: image,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
        // Soft shadow behind the main photo.
        Positioned(
          left: 70,
          right: -6,
          top: 152,
          bottom: 132,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.6),
                BlendMode.srcIn,
              ),
              child: Image(
                image: image,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          left: 50,
          right: -20,
          top: 136,
          bottom: 140,
          child: fadedBottom(
            Image(
              image: image,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsPortrait extends StatelessWidget {
  const _InitialsPortrait({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final serif = GoogleFonts.bodoniModa(
      fontWeight: FontWeight.w600,
      height: 1,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -60,
          top: 120,
          child: Text(
            initials,
            style: serif.copyWith(
              fontSize: 400,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 230,
          child: Center(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFF8FB8FF), _roleBlue],
              ).createShader(rect),
              child: Text(initials, style: serif.copyWith(fontSize: 220)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final nameParts = member.displayCardName.toUpperCase().split(
      RegExp(r'\s+'),
    );
    final firstLine = nameParts.first;
    final secondLine = nameParts.skip(1).join(' ');
    final roleParts = member.role
        .split('·')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final roleTitle = roleParts.first.replaceAll('-', ' ').toUpperCase();
    final roleDetail =
        (roleParts.length > 1
                ? roleParts.skip(1).join(' · ')
                : member.department ?? '')
            .toUpperCase();
    final nameStyle = GoogleFonts.bodoniModa(
      fontSize: 66,
      fontWeight: FontWeight.w500,
      height: 0.95,
      color: Colors.white,
    );

    return _CardSurface(
      child: Stack(
        children: [
          Positioned.fill(child: _HeroPortrait(member: member)),
          // Darken the lower area so the name stays readable over the photo.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 330,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0003050B), Color(0xCC03050B), _bgBottom],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 34,
            child: Center(child: _Brand()),
          ),
          Positioned(
            left: 32,
            right: 28,
            bottom: 142,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 6,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(firstLine, style: nameStyle),
                        if (secondLine.isNotEmpty)
                          Text(secondLine, style: nameStyle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(width: 2.5, height: 104, color: _roleBlue),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        roleTitle,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      if (roleDetail.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          roleDetail,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _roleBlue,
                            letterSpacing: 0.6,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            bottom: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'EMPLOYEE ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: VStackColors.muted,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.employeeId,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'vstackbusinesssolutions.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: VStackColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Front barcode holds the short employee ID so the bars stay wide enough to scan.
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BarcodeView(
                    barcode: Barcode.code128(),
                    data: member.employeeId,
                    width: 190,
                    height: 70,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final phone = contact.phoneDisplay ?? contact.whatsappNumber;
    final details = <(String, String)>[
      ('NAME', member.displayCardName),
      ('DESIGNATION', member.role),
      if (member.department != null) ('DEPARTMENT', member.department!),
      if (member.joinedOn != null) ('JOINED', member.joinedOn!),
      if (member.validUntil != null) ('VALID UNTIL', member.validUntil!),
      if (member.bloodGroup != null) ('BLOOD GROUP', member.bloodGroup!),
      if (member.phone != null) ('PHONE', member.phone!),
      if (member.email != null) ('EMAIL', member.email!),
    ];

    return _CardSurface(
      child: Stack(
        children: [
          Positioned(
            left: 40,
            right: 40,
            top: 230,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.07,
                child: Image.asset(BrandAssets.logoWhite, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned.fill(child: _backContent(phone, details)),
        ],
      ),
    );
  }

  Widget _backContent(String phone, List<(String, String)> details) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _Brand(scale: 0.9)),
          const SizedBox(height: 30),
          const Text(
            'EMPLOYEE ID',
            style: TextStyle(
              fontSize: 12,
              color: VStackColors.muted,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            member.employeeId,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(width: 56, height: 3, color: _roleBlue),
          ),
          const SizedBox(height: 18),
          for (final d in details.take(7))
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.$1,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: VStackColors.muted,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This card is the property of VStack Business Solutions. If found, please return it or call $phone.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: VStackColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contact.email,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _roleBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: BarcodeView(
                  barcode: Barcode.qrCode(
                    errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
                  ),
                  data: member.cardUrl,
                  width: 140,
                  height: 140,
                  color: _ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
