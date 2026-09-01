import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_themes.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';

class DeliveryMobileTemplate extends StatelessWidget {
  const DeliveryMobileTemplate({super.key});

  static const _steps = [
    ('Order placed', true),
    ('Restaurant preparing', true),
    ('Out for delivery', true),
    ('Delivered', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DemoThemes.delivery(),
      child: DemoDeviceFrame(
        type: DemoFrameType.phone,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [const Color(0xFFFC8019).withValues(alpha: 0.15), const Color(0xFFFFF8F3)],
                    ),
                    border: Border.all(color: const Color(0xFFFC8019).withValues(alpha: 0.2)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: 20, top: 20, child: Icon(Icons.delivery_dining, size: 48, color: const Color(0xFFFC8019).withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFC8019), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Arriving in 8 min', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                            const Spacer(),
                            const Text('Paragon Restaurant', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text('Chicken Biryani × 1, Lime Juice × 2', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 16, backgroundColor: const Color(0xFFEFF6FF), child: Icon(Icons.person, size: 18, color: Colors.blue.shade700)),
                      const SizedBox(width: 10),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Rajesh is on the way', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Hero Splendor • KL 08 AB 1234', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ])),
                      OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: Size.zero), child: const Text('Call', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Order Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: _steps.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: s.$2 ? const Color(0xFFFC8019) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: s.$2 ? const Color(0xFFFC8019) : Colors.grey.shade300, width: 2),
                              ),
                              child: s.$2 ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.$1, style: TextStyle(fontWeight: s.$2 ? FontWeight.w600 : FontWeight.normal, color: s.$2 ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))),
                                  if (s.$2 && s.$1 == 'Out for delivery') Text('Your food is on the way', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFC8019), minimumSize: const Size(double.infinity, 48)),
                    child: const Text('Track on map'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
