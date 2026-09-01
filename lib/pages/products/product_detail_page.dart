import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/models/product.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/cta_section.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/page_hero.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    final product = content.productBySlug(slug);
    if (product == null) {
      return const Center(child: Text('Product not found'));
    }

    if (product.isUpcoming) {
      return _UpcomingProductView(product: product);
    }
    return _LiveProductView(product: product);
  }
}

class _UpcomingProductView extends StatelessWidget {
  const _UpcomingProductView({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return PageScroll(
      child: Column(
        children: [
          PageSection(
            top: VStackSpacing.section,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(VStackSpacing.xxl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VStackRadius.xl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    VStackColors.surface,
                    VStackColors.accent2.withValues(alpha: 0.12),
                    VStackColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(color: VStackColors.accent2.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'COMING SOON',
                    style: TextStyle(
                      color: VStackColors.accent2,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: VStackSpacing.lg),
                  Text(
                    p.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  const SizedBox(height: VStackSpacing.md),
                  Text(
                    p.tagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: VStackColors.accent, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: VStackSpacing.lg),
                  Text(
                    p.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: VStackColors.muted, fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: VStackSpacing.xl),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: p.features
                        .map(
                          (f) => Chip(
                            label: Text(f),
                            backgroundColor: VStackColors.bg.withValues(alpha: 0.5),
                            side: BorderSide(color: VStackColors.accent.withValues(alpha: 0.25)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          CtaBanner(
            title: 'Be the first to know',
            subtitle: 'Join the waitlist for ${p.name} — a surprise platform from VSTACK.',
            buttonLabel: 'Join Waitlist',
            route: '/start-project?product=${p.slug}',
          ),
        ],
      ),
    );
  }
}

class _LiveProductView extends StatelessWidget {
  const _LiveProductView({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return PageScroll(
      child: Column(
        children: [
          PageHero(
            compact: true,
            badge: p.category,
            title: p.name,
            subtitle: p.tagline,
            primaryLabel: 'Request Demo',
            onPrimary: () => context.go('/start-project?product=${p.slug}'),
            secondaryLabel: 'Get Started',
            onSecondary: () => context.go('/start-project?product=${p.slug}'),
          ),
          if (p.screenshots.isNotEmpty)
            PageSection(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VStackRadius.lg),
                child: Image.asset(p.screenshots.first, fit: BoxFit.cover),
              ),
            ),
          PageSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: VStackSpacing.md),
                Text(p.description, style: const TextStyle(color: VStackColors.muted, height: 1.6, fontSize: 16)),
              ],
            ),
          ),
          PageSection(
            top: VStackSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Features', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: VStackSpacing.lg),
                FeatureGrid(features: p.features),
              ],
            ),
          ),
          if (p.releases.isNotEmpty) ...[
            PageSection(
              top: VStackSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Downloads', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: VStackSpacing.lg),
                  ...p.releases.expand((r) => r.platforms.map((pl) => _ReleaseRow(release: r, platform: pl))),
                ],
              ),
            ),
          ] else
            PageSection(
              top: VStackSpacing.lg,
              child: VStackCard(
                child: Text(
                  'Downloads coming soon. Contact us for early access to ${p.name}.',
                  style: const TextStyle(color: VStackColors.muted),
                ),
              ),
            ),
          CtaBanner(
            title: 'Ready to get started?',
            subtitle: 'Request a demo or get ${p.name} for your business.',
            buttonLabel: 'Request a Demo',
            route: '/start-project?product=${p.slug}',
          ),
        ],
      ),
    );
  }
}

class _ReleaseRow extends StatelessWidget {
  const _ReleaseRow({required this.release, required this.platform});
  final ProductRelease release;
  final ProductReleasePlatform platform;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VStackSpacing.sm),
      child: VStackCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${platform.platform.toUpperCase()} · v${release.version}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${platform.fileSize} · ${release.date}',
                      style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
                ],
              ),
            ),
            FilledButton(onPressed: () {}, child: const Text('Download')),
          ],
        ),
      ),
    );
  }
}
