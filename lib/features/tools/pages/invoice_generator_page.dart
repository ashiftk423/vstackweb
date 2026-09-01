import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/features/tools/models/invoice_currency.dart';
import 'package:vstackweb/features/tools/models/invoice_data.dart';
import 'package:vstackweb/features/tools/models/invoice_layout.dart';
import 'package:vstackweb/features/tools/services/file_download.dart';
import 'package:vstackweb/features/tools/services/invoice_pdf_builder.dart';
import 'package:vstackweb/features/tools/widgets/invoice_layout_previews.dart';
import 'package:vstackweb/features/tools/widgets/tool_page_shell.dart';
import 'package:vstackweb/features/tools/widgets/tool_split_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/features/tools/widgets/tool_upload_area.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class _LineItem {
  _LineItem({
    String desc = '',
    String qty = '1',
    String rate = '0',
    String tax = '18',
  })  : descController = TextEditingController(text: desc),
        qtyController = TextEditingController(text: qty),
        rateController = TextEditingController(text: rate),
        taxController = TextEditingController(text: tax);

  final TextEditingController descController;
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final TextEditingController taxController;

  String get desc => descController.text;
  double get qty => double.tryParse(qtyController.text) ?? 0;
  double get rate => double.tryParse(rateController.text) ?? 0;
  double get tax => double.tryParse(taxController.text) ?? 0;

  double get amount => qty * rate;
  double get taxAmount => amount * tax / 100;

  void dispose() {
    descController.dispose();
    qtyController.dispose();
    rateController.dispose();
    taxController.dispose();
  }
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
  final _items = [_LineItem(desc: 'Service / Product', rate: '1000')];

  InvoiceCurrency _currency = InvoiceCurrency.inr;
  InvoiceLayout _layout = InvoiceLayout.classic;
  Uint8List? _logoBytes;
  bool _downloading = false;

  InvoiceData get _invoiceData => InvoiceData(
        bizName: _bizName.text,
        bizAddr: _bizAddr.text,
        bizGst: _bizGst.text,
        custName: _custName.text,
        custAddr: _custAddr.text,
        invNo: _invNo.text,
        items: _items
            .map((i) => InvoiceLineItemData(
                  desc: i.desc,
                  qty: i.qty,
                  rate: i.rate,
                  tax: i.tax,
                ))
            .toList(),
        currency: _currency,
        layout: _layout,
        logoBytes: _logoBytes,
      );

  @override
  void dispose() {
    _bizName.dispose();
    _bizAddr.dispose();
    _bizGst.dispose();
    _custName.dispose();
    _custAddr.dispose();
    _invNo.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _addItem() {
    setState(() => _items.add(_LineItem()));
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _pickLogo() async {
    final files = await ToolUploadArea.pickFiles(type: FileType.image);
    if (files.isEmpty || files.first.bytes == null) return;
    setState(() => _logoBytes = files.first.bytes);
  }

  Future<void> _downloadPdf() async {
    setState(() => _downloading = true);
    try {
      final bytes = await InvoicePdfBuilder.build(_invoiceData);
      downloadBytes(bytes, 'invoice-${_invNo.text}.pdf', mimeType: 'application/pdf');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(labelText: label);

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
              TextField(
                controller: _bizName,
                textDirection: TextDirection.ltr,
                decoration: _fieldDecoration('Business name'),
                onChanged: (_) => _refresh(),
              ),
              TextField(
                controller: _bizAddr,
                textDirection: TextDirection.ltr,
                decoration: _fieldDecoration('Address'),
                onChanged: (_) => _refresh(),
              ),
              TextField(
                controller: _bizGst,
                textDirection: TextDirection.ltr,
                decoration: _fieldDecoration('GSTIN'),
                onChanged: (_) => _refresh(),
              ),
              const SizedBox(height: VStackSpacing.sm),
              _LogoUploadRow(
                logoBytes: _logoBytes,
                onPick: _pickLogo,
                onRemove: () => setState(() => _logoBytes = null),
              ),
              const SizedBox(height: VStackSpacing.md),
              const Text('Customer', style: TextStyle(fontWeight: FontWeight.w700)),
              TextField(
                controller: _custName,
                textDirection: TextDirection.ltr,
                decoration: _fieldDecoration('Customer name'),
                onChanged: (_) => _refresh(),
              ),
              TextField(
                controller: _custAddr,
                textDirection: TextDirection.ltr,
                decoration: _fieldDecoration('Address'),
                onChanged: (_) => _refresh(),
              ),
              TextField(
                controller: _invNo,
                textDirection: TextDirection.ltr,
                decoration: _fieldDecoration('Invoice number'),
                onChanged: (_) => _refresh(),
              ),
              const SizedBox(height: VStackSpacing.md),
              DropdownButtonFormField<InvoiceCurrency>(
                value: _currency,
                decoration: _fieldDecoration('Currency'),
                items: InvoiceCurrency.values
                    .map((c) => DropdownMenuItem(value: c, child: Text('${c.code} (${c.symbol})')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _currency = v);
                },
              ),
              const SizedBox(height: VStackSpacing.md),
              const Text('Line items', style: TextStyle(fontWeight: FontWeight.w700)),
              ..._items.asMap().entries.map((e) {
                final index = e.key;
                final item = e.value;
                return _LineItemFields(
                  index: index,
                  item: item,
                  canRemove: _items.length > 1,
                  decoration: _fieldDecoration,
                  onChanged: _refresh,
                  onRemove: () => _removeItem(index),
                );
              }),
              TextButton(onPressed: _addItem, child: const Text('+ Add item')),
            ],
          ),
        ),
        preview: VStackCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<InvoiceLayout>(
                  segments: InvoiceLayout.values
                      .map((l) => ButtonSegment(value: l, label: Text(l.label)))
                      .toList(),
                  selected: {_layout},
                  onSelectionChanged: (s) => setState(() => _layout = s.first),
                ),
              ),
              const SizedBox(height: VStackSpacing.md),
              InvoiceLayoutPreview(data: _invoiceData),
              const SizedBox(height: VStackSpacing.lg),
              if (_downloading)
                const ToolProcessingIndicator(label: 'Generating PDF…')
              else
                ToolDownloadButton(label: 'Download PDF', onPressed: _downloadPdf),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineItemFields extends StatelessWidget {
  const _LineItemFields({
    required this.index,
    required this.item,
    required this.canRemove,
    required this.decoration,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _LineItem item;
  final bool canRemove;
  final InputDecoration Function(String label) decoration;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: item.descController,
                  textDirection: TextDirection.ltr,
                  decoration: decoration('Item ${index + 1}'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Remove item',
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.qtyController,
                  textDirection: TextDirection.ltr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: decoration('Qty'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: item.rateController,
                  textDirection: TextDirection.ltr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: decoration('Price'),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: item.taxController,
                  textDirection: TextDirection.ltr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: decoration('GST %'),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoUploadRow extends StatelessWidget {
  const _LogoUploadRow({
    required this.logoBytes,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? logoBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.image_outlined, size: 18),
          label: const Text('Upload logo'),
        ),
        if (logoBytes != null) ...[
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(logoBytes!, width: 40, height: 40, fit: BoxFit.contain),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Remove logo',
            onPressed: onRemove,
          ),
        ],
      ],
    );
  }
}
