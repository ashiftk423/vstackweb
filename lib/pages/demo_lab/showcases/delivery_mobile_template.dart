import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class DeliveryMobileTemplate extends StatelessWidget {
  const DeliveryMobileTemplate({super.key});

  static const _steps = [
    ('Order placed', true),
    ('Preparing', true),
    ('Out for delivery', true),
    ('Delivered', false),
  ];

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.phone,
      child: Scaffold(
        backgroundColor: VStackColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 140,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [VStackColors.accent.withValues(alpha: 0.3), VStackColors.surface],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VStackColors.border),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delivery_dining, size: 36, color: VStackColors.accent),
                      SizedBox(height: 8),
                      Text('Driver is 8 min away', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('In transit', style: TextStyle(fontSize: 11, color: Colors.orange)),
                    ),
                    const Spacer(),
                    const Text('Order #4821', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _steps.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: s.$2 ? VStackColors.accent : VStackColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: VStackColors.border),
                            ),
                            child: s.$2 ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Text(s.$1, style: TextStyle(
                            fontWeight: s.$2 ? FontWeight.w600 : FontWeight.normal,
                            color: s.$2 ? Colors.white : VStackColors.muted,
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(onPressed: () {}, child: const Text('Contact Driver')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
