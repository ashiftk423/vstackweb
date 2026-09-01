import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_cart_panel.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_product_card.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_search_header.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';

class EcommerceStorefrontTemplate extends StatefulWidget {
  const EcommerceStorefrontTemplate({super.key});

  @override
  State<EcommerceStorefrontTemplate> createState() => _EcommerceStorefrontTemplateState();
}

class _EcommerceStorefrontTemplateState extends State<EcommerceStorefrontTemplate> {
  String _category = 'All';
  final _cart = <String, DemoCartLine>{};
  DemoProduct? _quickView;
  bool _showCart = false;
  int _cartAnimKey = 0;

  List<DemoProduct> get _filtered {
    if (_category == 'All') return DemoSampleData.products;
    return DemoSampleData.products.where((p) => p.category == _category).toList();
  }

  int get _cartCount => _cart.values.fold(0, (s, l) => s + l.qty);

  void _addToCart(DemoProduct p) {
    setState(() {
      _cartAnimKey++;
      final existing = _cart[p.id];
      if (existing != null) {
        existing.qty++;
      } else {
        _cart[p.id] = DemoCartLine(product: p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.browser,
      title: 'shop',
      child: DemoTemplateScaffold(
        theme: DemoThemes.ecommerce(),
        backgroundColor: const Color(0xFFF1F3F6),
        header: DemoSearchHeader(
          brand: 'ShopKart',
          cartCount: _cartCount,
          onCartTap: () => setState(() => _showCart = true),
        ).animate(key: ValueKey(_cartAnimKey)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 150.ms).then().scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1), duration: 150.ms),
        body: Stack(
          children: [
            Column(
              children: [
                DemoCategoryStrip(
                  categories: DemoSampleData.categories,
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
                DemoHeroBanner(imagePath: DemoSampleData.ecommerceBanner),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      return DemoProductCard(
                        product: p,
                        onTap: () => setState(() => _quickView = p),
                        onAddToCart: () => _addToCart(p),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_quickView != null) _QuickViewSheet(
              product: _quickView!,
              onClose: () => setState(() => _quickView = null),
              onAdd: () {
                _addToCart(_quickView!);
                setState(() => _quickView = null);
              },
            ),
            if (_showCart)
              Row(
                children: [
                  Expanded(child: GestureDetector(onTap: () => setState(() => _showCart = false), child: Container(color: Colors.black45))),
                  SizedBox(
                    width: 300,
                    child: DemoCartPanel(
                      lines: _cart.values.toList(),
                      onQtyChanged: (p, q) => setState(() => _cart[p.id]?.qty = q),
                      onRemove: (p) => setState(() => _cart.remove(p.id)),
                      onCheckout: () => setState(() { _cart.clear(); _showCart = false; }),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}

class _QuickViewSheet extends StatelessWidget {
  const _QuickViewSheet({required this.product, required this.onClose, required this.onAdd});

  final DemoProduct product;
  final VoidCallback onClose;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 16,
        child: SizedBox(
          height: 340,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(product.image, width: 140, height: 140, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text('₹${product.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                            Text('MRP ₹${product.mrp}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xFF878787))),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(child: OutlinedButton(onPressed: onClose, child: const Text('Close'))),
                                const SizedBox(width: 8),
                                Expanded(child: FilledButton(onPressed: onAdd, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFB641B)), child: const Text('Add to Cart'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
    );
  }
}
