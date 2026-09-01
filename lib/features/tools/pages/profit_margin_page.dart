import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ProfitMarginPage extends StatefulWidget {
  const ProfitMarginPage({super.key});

  @override
  State<ProfitMarginPage> createState() => _ProfitMarginPageState();
}

class _ProfitMarginPageState extends State<ProfitMarginPage> {
  final _cost = TextEditingController(text: '100');
  final _sell = TextEditingController(text: '150');
  final _qty = TextEditingController(text: '1');

  @override
  void dispose() {
    _cost.dispose();
    _sell.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cost = double.tryParse(_cost.text) ?? 0;
    final sell = double.tryParse(_sell.text) ?? 0;
    final qty = double.tryParse(_qty.text) ?? 1;
    final profitUnit = sell - cost;
    final totalProfit = profitUnit * qty;
    final profitPct = cost > 0 ? (profitUnit / cost) * 100 : 0;
    final marginPct = sell > 0 ? (profitUnit / sell) * 100 : 0;
    final markupPct = cost > 0 ? (profitUnit / cost) * 100 : 0;

    return ToolPageShell(
      tool: ToolsRegistry.profitMarginCalculator,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: VStackCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _cost, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost price'), onChanged: (_) => setState(() {})),
                const SizedBox(height: VStackSpacing.md),
                TextField(controller: _sell, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling price'), onChanged: (_) => setState(() {})),
                const SizedBox(height: VStackSpacing.md),
                TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'), onChanged: (_) => setState(() {})),
                const SizedBox(height: VStackSpacing.lg),
                _row('Profit per unit', '₹${profitUnit.toStringAsFixed(2)}'),
                _row('Total profit', '₹${totalProfit.toStringAsFixed(2)}'),
                _row('Profit %', '${profitPct.toStringAsFixed(1)}%'),
                _row('Margin %', '${marginPct.toStringAsFixed(1)}%'),
                _row('Markup %', '${markupPct.toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(l, style: const TextStyle(color: VStackColors.muted)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))],
        ),
      );
}
