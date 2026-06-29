import 'package:flutter/material.dart';
import 'package:vstackweb/constants/brand_assets.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class VStackLogo extends StatelessWidget {
  const VStackLogo({
    super.key,
    this.size = 42,
    this.showLabel = true,
    this.compact = false,
  });

  final double size;
  final bool showLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.28),
          child: Image.asset(
            BrandAssets.logo,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.28),
                gradient: const LinearGradient(
                  colors: [VStackColors.accent, VStackColors.accent2],
                ),
              ),
              child: Text(
                'V',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.42,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (showLabel && !compact) ...[
          SizedBox(width: size * 0.24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VStack',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Text(
                'Business Solutions',
                style: TextStyle(color: VStackColors.muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
