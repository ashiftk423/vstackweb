import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class _LineItem {
  _LineItem({this.desc = '', this.qty = 1, this.rate = 0, this.discount = 0, this.tax = 18});
  String desc;
  double qty;
  double rate;
  double discount;
  double tax;
  double get amount => qty * rate * (1 - discount / 100);
  double get taxAmount => amount * tax / 100;
}

class InvoiceGeneratorPage extends StatefulWidget {
  const InvoiceGeneratorPage({super.key});

  @override
  State<InvoiceGeneratorPage> createState() => _InvoiceGeneratorPageState();
}

class _InvoiceGeneratorPageState extends State<InvoiceGeneratorPage> {
  final _bizName = TextEditingController(text: 'Your Business');
  final _bizAddr = TextEditingController();
  final _bizGst = TextEditingController();
  final _custName = TextEditingController(text: 'Customer');
  final _custAddr = TextEditingController();
  final _invNo = TextEditingController(text: 'INV-001');
  final _items = [_LineItem(desc: 'Service / Product', qty: 1, rate: 1000)];

  double get _subtotal => _items.fold(0, (s, i) => s + i.amount);
  double get _taxTotal => _items.fold(0, (s, i) => s + i.taxAmount);
  double get _total => _subtotal + _taxTotal;

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_bizName.text, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text(_bizAddr.text),
            if (_bizGst.text.isNotEmpty) pw.Text('GSTIN: ${_bizGst.text}'),
            pw.SizedBox(height: 24),
            pw.Text('Invoice #${_invNo.text}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('Bill To: ${_custName.text}'),
            pw.Text(_custAddr.text),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Item', 'Qty', 'Rate', 'Amount'],
              data: [
                ..._items.map((i) => [i.desc, '${i.qty}', '₹${i.rate}', '₹${i.amount.toStringAsFixed(2)}']),
                ['', '', 'Subtotal', '₹${_subtotal.toStringAsFixed(2)}'],
                ['', '', 'Tax', '₹${_taxTotal.toStringAsFixed(2)}'],
                ['', '', 'Total', '₹${_total.toStringAsFixed(2)}'],
              ],
            ),
            pw.Spacer(),
            pw.Text('Powered by VSTACK', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
    final bytes = await pdf.save();
    downloadBytes(bytes, 'invoice-${_invNo.text}.pdf', mimeType: 'application/pdf');
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      tool: ToolsRegistry.invoiceGenerator,
      child: ToolSplitLayout(
        input: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Business', style: TextStyle(fontWeight: FontWeight.w700)),
              TextField(controller: _bizName, decoration: const InputDecoration(labelText: 'Business name'), onChanged: (_) => setState(() {})),
              TextField(controller: _bizAddr, decoration: const InputDecoration(labelText: 'Address'), onChanged: (_) => setState(() {})),
              TextField(controller: _bizGst, decoration: const InputDecoration(labelText: 'GSTIN'), onChanged: (_) => setState(() {})),
              const SizedBox(height: VStackSpacing.md),
              const Text('Customer', style: TextStyle(fontWeight: FontWeight.w700)),
              TextField(controller: _custName, decoration: const InputDecoration(labelText: 'Customer name'), onChanged: (_) => setState(() {})),
              TextField(controller: _custAddr, decoration: const InputDecoration(labelText: 'Address'), onChanged: (_) => setState(() {})),
              TextField(controller: _invNo, decoration: const InputDecoration(labelText: 'Invoice number'), onChanged: (_) => setState(() {})),
              const SizedBox(height: VStackSpacing.md),
              ..._items.asMap().entries.map((e) {
                final i = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Item ${e.key + 1}'),
                    controller: TextEditingController(text: i.desc),
                    onChanged: (v) => setState(() => i.desc = v),
                  ),
                );
              }),
              TextButton(onPressed: () => setState(() => _items.add(_LineItem())), child: const Text('+ Add item')),
            ],
          ),
        ),
        preview: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_bizName.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(_custName.text, style: const TextStyle(color: VStackColors.muted)),
              const Divider(height: 24),
              ..._items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Expanded(child: Text(i.desc)), Text('₹${i.amount.toStringAsFixed(2)}')],
                    ),
                  )),
              const Divider(height: 24),
              ToolResultCard(
                title: 'Summary',
                rows: [
                  ('Subtotal', '₹${_subtotal.toStringAsFixed(2)}'),
                  ('Tax', '₹${_taxTotal.toStringAsFixed(2)}'),
                  ('Total', '₹${_total.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: VStackSpacing.lg),
              ToolDownloadButton(label: 'Download PDF', onPressed: _downloadPdf),
            ],
          ),
        ),
      ),
    );
  }
}
