import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';

class DemoPosTile extends StatelessWidget {
  const DemoPosTile({super.key, required this.item, required this.onTap});

  final DemoPosItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(item.image, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF5F5F5), child: const Icon(Icons.restaurant))),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(color: item.veg ? Colors.green : Colors.red, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: item.veg ? Colors.green : Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  const SizedBox(height: 2),
                  Text('₹${item.price}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF00A651))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
