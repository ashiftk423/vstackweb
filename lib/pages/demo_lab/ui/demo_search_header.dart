import 'package:flutter/material.dart';

class DemoSearchHeader extends StatelessWidget {
  const DemoSearchHeader({
    super.key,
    required this.brand,
    this.cartCount = 0,
    this.onCartTap,
    this.light = true,
  });

  final String brand;
  final int cartCount;
  final VoidCallback? onCartTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: light ? const Color(0xFF2874F0) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(brand, style: TextStyle(color: light ? Colors.white : const Color(0xFF2874F0), fontWeight: FontWeight.w800, fontSize: 18, fontStyle: FontStyle.italic)),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Search for products, brands and more', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onCartTap,
                icon: Icon(Icons.shopping_cart_outlined, color: light ? Colors.white : const Color(0xFF2874F0)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              if (cartCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFFF6161), shape: BoxShape.circle),
                    child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DemoCategoryStrip extends StatelessWidget {
  const DemoCategoryStrip({super.key, required this.categories, required this.selected, required this.onSelected});

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i];
          final active = c == selected;
          return GestureDetector(
            onTap: () => onSelected(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2874F0) : const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : const Color(0xFF565656))),
            ),
          );
        },
      ),
    );
  }
}

class DemoHeroBanner extends StatelessWidget {
  const DemoHeroBanner({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(imagePath, height: 100, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(
          height: 100,
          color: const Color(0xFF2874F0),
          child: const Center(child: Text('Big Billion Days Sale — Up to 70% Off', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        )),
      ),
    );
  }
}
