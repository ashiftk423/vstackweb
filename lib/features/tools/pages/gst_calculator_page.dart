import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class GstCalculatorPage extends StatefulWidget {
  const GstCalculatorPage({super.key});

  @override
  State<GstCalculatorPage> createState() => _GstCalculatorPageState();
}

class _GstCalculatorPageState extends State<GstCalculatorPage> {
  final _amountCtrl = TextEditingController(text: '1000');
  bool _inclusive = false;
  double _rate = 18;
  final _customRateCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _customRateCtrl.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;
  double get _gstRate => _rate == -1 ? (double.tryParse(_customRateCtrl.text) ?? 0) : _rate;

  Map<String, double> get _result {
    if (_amount <= 0 || _gstRate < 0) {
      return {'base': 0, 'gst': 0, 'cgst': 0, 'sgst': 0, 'total': 0};
    }
    if (_inclusive) {
      final base = _amount / (1 + _gstRate / 100);
      final gst = _amount - base;
      return {'base': base, 'gst': gst, 'cgst': gst / 2, 'sgst': gst / 2, 'total': _amount};
    }
    final gst = _amount * _gstRate / 100;
    return {'base': _amount, 'gst': gst, 'cgst': gst / 2, 'sgst': gst / 2, 'total': _amount + gst};
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ToolPageShell(
      tool: ToolsRegistry.gstCalculator,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: VStackCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: VStackSpacing.md),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('GST Exclusive')),
                    ButtonSegment(value: true, label: Text('GST Inclusive')),
                  ],
                  selected: {_inclusive},
                  onSelectionChanged: (s) => setState(() => _inclusive = s.first),
                ),
                const SizedBox(height: VStackSpacing.md),
                Wrap(
                  spacing: 8,
                  children: [5.0, 12.0, 18.0, 28.0, -1.0].map((rate) {
                    final label = rate == -1 ? 'Custom' : '${rate.toInt()}%';
                    return ChoiceChip(
                      label: Text(label),
                      selected: _rate == rate,
                      onSelected: (_) => setState(() => _rate = rate),
                    );
                  }).toList(),
                ),
                if (_rate == -1) ...[
                  const SizedBox(height: VStackSpacing.sm),
                  TextField(
                    controller: _customRateCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Custom GST %'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: VStackSpacing.lg),
                _row('Base amount', '₹${r['base']!.toStringAsFixed(2)}'),
                _row('GST (${_gstRate.toStringAsFixed(1)}%)', '₹${r['gst']!.toStringAsFixed(2)}'),
                _row('CGST', '₹${r['cgst']!.toStringAsFixed(2)}'),
                _row('SGST', '₹${r['sgst']!.toStringAsFixed(2)}'),
                const Divider(height: 24),
                _row('Total', '₹${r['total']!.toStringAsFixed(2)}', bold: true),
                const SizedBox(height: VStackSpacing.sm),
                Text(
                  'For reference only. Verify tax obligations with a qualified professional.',
                  style: TextStyle(color: VStackColors.muted.withValues(alpha: 0.8), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? null : VStackColors.muted)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 18 : 14)),
        ],
      ),
    );
  }
}
