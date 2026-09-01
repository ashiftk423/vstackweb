import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class EcommerceStorefrontTemplate extends StatefulWidget {
  const EcommerceStorefrontTemplate({super.key});

  @override
  State<EcommerceStorefrontTemplate> createState() => _EcommerceStorefrontTemplateState();
}

class _EcommerceStorefrontTemplateState extends State<EcommerceStorefrontTemplate> {
  int _cartCount = 0;
  int? _quickView;

  static const _products = [
    ('Wireless Earbuds', '₹2,499', Icons.headphones),
    ('Smart Watch', '₹4,999', Icons.watch),
    ('Leather Bag', '₹3,299', Icons.shopping_bag),
    ('Running Shoes', '₹5,499', Icons.directions_run),
    ('Desk Lamp', '₹1,899', Icons.light),
    ('Coffee Maker', '₹6,999', Icons.coffee),
  ];

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'shop',
      child: DemoTemplateScaffold(
        brand: 'ShopWave',
        navItems: ['Shop', 'New', 'Sale', 'Cart ($_cartCount)'],
        body: Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _products.length,
              itemBuilder: (_, i) {
                final p = _products[i];
                return GestureDetector(
                  onTap: () => setState(() => _quickView = i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: VStackColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VStackColors.border),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(p.$3, size: 36, color: VStackColors.accent),
                        const Spacer(),
                        Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        Text(p.$2, style: const TextStyle(color: VStackColors.accent, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_quickView != null)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: VStackColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_products[_quickView!].$3, size: 48, color: VStackColors.accent),
                        const SizedBox(height: 12),
                        Text(_products[_quickView!].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(_products[_quickView!].$2, style: const TextStyle(color: VStackColors.accent)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _quickView = null),
                                child: const Text('Close'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _cartCount++;
                                    _quickView = null;
                                  });
                                },
                                child: const Text('Add to Cart'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
