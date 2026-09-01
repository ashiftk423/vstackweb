import 'package:flutter/material.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';
import 'package:vstackweb/widgets/page_hero.dart';
import 'package:vstackweb/widgets/page_scroll.dart';
import 'package:vstackweb/widgets/product_card.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = SiteContentScope.of(context);
    return PageScroll(
      child: Column(
        children: [
          const PageHero(
            compact: true,
            badge: 'Products',
            title: 'VSTACK-owned products',
            subtitle: 'Software platforms built and maintained by VSTACK — not client projects.',
          ),
          PageSection(
            child: ResponsiveGrid(
              itemCount: content.products.length,
              desktopColumns: 3,
              itemBuilder: (_, i) => ProductCard(product: content.products[i]),
            ),
          ),
        ],
      ),
    );
  }
}
