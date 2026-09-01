import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/models/product.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return VStackCard(
      onTap: () => context.go('/products/${product.slug}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProductLogo(product: product),
              const Spacer(),
              _StatusBadge(status: product.status),
            ],
          ),
          const SizedBox(height: VStackSpacing.md),
          Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            product.tagline,
            style: const TextStyle(color: VStackColors.accent2, fontSize: 12),
          ),
          const SizedBox(height: VStackSpacing.sm),
          Text(
            product.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: VStackColors.muted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: VStackSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: product.platforms
                .map((p) => Chip(
                      label: Text(p, style: const TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: VStackColors.bg.withValues(alpha: 0.5),
                      side: const BorderSide(color: VStackColors.border),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ProductLogo extends StatelessWidget {
  const _ProductLogo({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.logo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(VStackRadius.sm),
        child: Image.asset(product.logo!, width: 48, height: 48, fit: BoxFit.cover),
      );
    }
    if (product.screenshots.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(VStackRadius.sm),
        child: Image.asset(
          product.screenshots.first,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials(),
        ),
      );
    }
    return _initials();
  }

  Widget _initials() {
    final initials = product.name.length >= 2 ? product.name.substring(0, 2).toUpperCase() : product.name;
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: product.isUpcoming
              ? [VStackColors.accent2.withValues(alpha: 0.4), VStackColors.accent.withValues(alpha: 0.3)]
              : [VStackColors.accent, VStackColors.accent2],
        ),
        borderRadius: BorderRadius.circular(VStackRadius.sm),
      ),
      child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final live = status == 'live';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (live ? VStackColors.accent : VStackColors.accent2).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (live ? VStackColors.accent : VStackColors.accent2).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        live ? 'Live' : 'Coming Soon',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: live ? VStackColors.accent : VStackColors.accent2,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
