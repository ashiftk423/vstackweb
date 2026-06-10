import 'package:flutter/material.dart';
import 'package:vstackweb/theme/responsive.dart';

/// Asset image that scales height by screen width.
class ResponsiveAssetImage extends StatelessWidget {
  const ResponsiveAssetImage({
    super.key,
    required this.assetPath,
    this.borderRadius = 12,
    this.mobileHeight = 140,
    this.desktopHeight = 100,
  });

  final String assetPath;
  final double borderRadius;
  final double mobileHeight;
  final double desktopHeight;

  @override
  Widget build(BuildContext context) {
    final height = AppLayout.isMobile(context) ? mobileHeight : desktopHeight;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
