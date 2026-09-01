import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_rating_stars.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';

class DemoProductCard extends StatefulWidget {
  const DemoProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final DemoProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  State<DemoProductCard> createState() => _DemoProductCardState();
}

class _DemoProductCardState extends State<DemoProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _hover ? -2.0 : 0.0),
        child: Material(
          color: Colors.white,
          elevation: _hover ? 4 : 1,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(p.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF1F3F6), child: const Icon(Icons.image))),
                      ),
                    ),
                    if (p.badge != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFF6161), borderRadius: BorderRadius.circular(3)),
                          child: Text(p.badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    if (p.discountPercent > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF388E3C), borderRadius: BorderRadius.circular(3)),
                          child: Text('${p.discountPercent}% off', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3, color: Color(0xFF212121)),
                        ),
                        const SizedBox(height: 6),
                        DemoRatingStars(rating: p.rating),
                        const SizedBox(height: 4),
                        Text('(${_formatCount(p.reviewCount)})', style: const TextStyle(fontSize: 10, color: Color(0xFF878787))),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${_formatPrice(p.price)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                            const SizedBox(width: 6),
                            Text('₹${_formatPrice(p.mrp)}', style: const TextStyle(fontSize: 11, color: Color(0xFF878787), decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                        if (widget.onAddToCart != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: OutlinedButton(
                              onPressed: widget.onAddToCart,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2874F0),
                                side: const BorderSide(color: Color(0xFF2874F0)),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _formatCount(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
