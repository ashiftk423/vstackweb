import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_cart_panel.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_pos_tile.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_template_scaffold.dart';

class DesktopPosTemplate extends StatefulWidget {
  const DesktopPosTemplate({super.key});

  @override
  State<DesktopPosTemplate> createState() => _DesktopPosTemplateState();
}

class _DesktopPosTemplateState extends State<DesktopPosTemplate> {
  String _category = 'All';
  String _orderType = 'Dine-in';
  final _cart = <String, DemoCartLine>{};

  List<DemoPosItem> get _items {
    if (_category == 'All') return DemoSampleData.posItems;
    return DemoSampleData.posItems.where((i) => i.category == _category).toList();
  }

  List<DemoCartLine> get _lines {
    return _cart.values.map((line) {
      final pos = DemoSampleData.posItems.firstWhere((p) => p.id == line.product.id);
      return DemoCartLine(product: DemoProduct(
        id: pos.id,
        name: pos.name,
        price: pos.price,
        mrp: pos.price,
        rating: 4,
        reviewCount: 0,
        image: pos.image,
        category: pos.category,
      ), qty: line.qty);
    }).toList();
  }

  void _addItem(DemoPosItem item) {
    setState(() {
      final existing = _cart[item.id];
      if (existing != null) {
        existing.qty++;
      } else {
        _cart[item.id] = DemoCartLine(product: DemoProduct(
          id: item.id, name: item.name, price: item.price, mrp: item.price,
          rating: 4, reviewCount: 0, image: item.image, category: item.category,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.desktop,
      title: 'PetPooja POS',
      child: DemoTemplateScaffold(
        theme: DemoThemes.pos(),
        backgroundColor: const Color(0xFFF5F7FA),
        header: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: Color(0xFF00A651), size: 22),
              const SizedBox(width: 8),
              const Text('VSTACK Café — Thrissur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              ...['Dine-in', 'Takeaway'].map((t) {
                final sel = _orderType == t;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(t, style: const TextStyle(fontSize: 11)),
                    selected: sel,
                    onSelected: (_) => setState(() => _orderType = t),
                    selectedColor: const Color(0xFF00A651).withValues(alpha: 0.15),
                  ),
                );
              }),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                child: const Text('Table 5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        body: Row(
          children: [
            Container(
              width: 100,
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: DemoSampleData.posCategories.map((c) {
                  final sel = _category == c;
                  return Material(
                    color: sel ? const Color(0xFFE8F5E9) : Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _category = c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(c, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.normal, color: sel ? const Color(0xFF00A651) : const Color(0xFF666666))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => DemoPosTile(item: _items[i], onTap: () => _addItem(_items[i])),
                ),
              ),
            ),
            SizedBox(
              width: 260,
              child: DemoCartPanel(
                compact: true,
                lines: _lines,
                onQtyChanged: (p, q) => setState(() => _cart[p.id]?.qty = q),
                onRemove: (p) => setState(() => _cart.remove(p.id)),
                onCheckout: () => setState(() => _cart.clear()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
