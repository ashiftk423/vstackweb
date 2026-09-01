import 'package:flutter/material.dart';
import 'package:vstackweb/pages/demo_lab/ui/demo_sample_data.dart';

class DemoCartLine {
  DemoCartLine({required this.product, this.qty = 1});
  final DemoProduct product;
  int qty;
}

class DemoCartPanel extends StatelessWidget {
  const DemoCartPanel({
    super.key,
    required this.lines,
    required this.onQtyChanged,
    required this.onRemove,
    required this.onCheckout,
    this.compact = false,
  });

  final List<DemoCartLine> lines;
  final void Function(DemoProduct product, int qty) onQtyChanged;
  final void Function(DemoProduct product) onRemove;
  final VoidCallback onCheckout;
  final bool compact;

  int get _subtotal => lines.fold(0, (s, l) => s + l.product.price * l.qty);
  int get _gst => (_subtotal * 0.05).round();
  int get _total => _subtotal + _gst;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                const Text('Your Cart', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text('${lines.length} items', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: lines.isEmpty
                ? Center(child: Text('Cart is empty', style: TextStyle(color: Colors.grey.shade500)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: lines.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200, height: 16),
                    itemBuilder: (_, i) {
                      final line = lines[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(line.product.image, width: 56, height: 56, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('₹${line.product.price}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _QtyBtn(icon: Icons.remove, onTap: line.qty > 1 ? () => onQtyChanged(line.product, line.qty - 1) : null),
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${line.qty}', style: const TextStyle(fontWeight: FontWeight.w600))),
                                    _QtyBtn(icon: Icons.add, onTap: () => onQtyChanged(line.product, line.qty + 1)),
                                    const Spacer(),
                                    IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => onRemove(line.product), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (lines.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  _row('Subtotal', _subtotal),
                  if (compact) _row('GST (5%)', _gst),
                  const Divider(),
                  _row('Total', _total, bold: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      onPressed: onCheckout,
                      style: FilledButton.styleFrom(backgroundColor: compact ? const Color(0xFF00A651) : const Color(0xFFFB641B)),
                      child: Text(compact ? 'Pay ₹$_total' : 'Place Order — ₹$_total', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, color: bold ? const Color(0xFF212121) : const Color(0xFF565656))),
          const Spacer(),
          Text('₹$amount', style: TextStyle(fontSize: bold ? 16 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F6),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 16, color: onTap == null ? Colors.grey : const Color(0xFF2874F0))),
      ),
    );
  }
}
