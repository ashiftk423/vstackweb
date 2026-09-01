import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class PosDemo extends StatefulWidget {
  const PosDemo({super.key});

  @override
  State<PosDemo> createState() => _PosDemoState();
}

class _PosDemoState extends State<PosDemo> {
  final _cart = <String, int>{};
  final _products = ['Coffee', 'Sandwich', 'Juice', 'Cake', 'Water', 'Snack'];

  double get _total => _cart.entries.fold(0, (s, e) => s + e.value * 120);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VStackColors.bg,
      padding: const EdgeInsets.all(VStackSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _products.map((p) {
                return SizedBox(
                  width: 120,
                  child: VStackCard(
                    onTap: () => setState(() => _cart[p] = (_cart[p] ?? 0) + 1),
                    padding: const EdgeInsets.all(VStackSpacing.md),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: VStackColors.accent),
                        const SizedBox(height: 8),
                        Text(p, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Text('₹120', style: TextStyle(color: VStackColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: VStackSpacing.lg),
          Expanded(
            child: VStackCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Bill (Sample)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: VStackSpacing.md),
                  ..._cart.entries.map((e) => Text('${e.key} x${e.value}')),
                  const Divider(),
                  Text('Total: ₹${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: VStackSpacing.md),
                  FilledButton(onPressed: () {}, child: const Text('Print Bill')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
