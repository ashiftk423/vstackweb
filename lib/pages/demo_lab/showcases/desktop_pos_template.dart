import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/widgets/demo_device_frame.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class DesktopPosTemplate extends StatefulWidget {
  const DesktopPosTemplate({super.key});

  @override
  State<DesktopPosTemplate> createState() => _DesktopPosTemplateState();
}

class _DesktopPosTemplateState extends State<DesktopPosTemplate> {
  final _cart = <String, int>{};
  static const _products = {
    'Tea': 25,
    'Coffee': 40,
    'Sandwich': 80,
    'Juice': 50,
    'Cake': 60,
    'Water': 20,
  };

  double get _total => _cart.entries.fold(0, (sum, e) => sum + _products[e.key]! * e.value);

  @override
  Widget build(BuildContext context) {
    return DemoDeviceFrame(
      type: DemoFrameType.desktop,
      title: 'POS Terminal',
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: VStackColors.bg,
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: _products.length,
                itemBuilder: (_, i) {
                  final name = _products.keys.elementAt(i);
                  final price = _products[name]!;
                  return Material(
                    color: VStackColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _cart[name] = (_cart[name] ?? 0) + 1),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: VStackColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('₹$price', style: const TextStyle(color: VStackColors.accent, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: 220,
            color: VStackColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Current Bill', style: TextStyle(fontWeight: FontWeight.w700)),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: _cart.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text('${e.key} ×${e.value}', style: const TextStyle(fontSize: 12))),
                            Text('₹${_products[e.key]! * e.value}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Text('Total: ₹${_total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _cart.isEmpty ? null : () => setState(() => _cart.clear()),
                  child: const Text('Print Bill'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
