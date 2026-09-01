import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/models/invoice_data.dart';
import 'package:vstackweb/features/tools/models/invoice_layout.dart';
import 'package:vstackweb/features/tools/widgets/tool_status_widgets.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class InvoiceLayoutPreview extends StatelessWidget {
  const InvoiceLayoutPreview({super.key, required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return switch (data.layout) {
      InvoiceLayout.classic => _ClassicPreview(data: data),
      InvoiceLayout.modern => _ModernPreview(data: data),
      InvoiceLayout.gstIndia => _GstIndiaPreview(data: data),
      InvoiceLayout.gulf => _GulfPreview(data: data),
    };
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.logoBytes, this.size = 56});

  final Uint8List? logoBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (logoBytes == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(logoBytes!, width: size, height: size, fit: BoxFit.contain),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.center)),
            Expanded(child: Text('Rate', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.end)),
            Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.end)),
          ],
        ),
        const Divider(height: 16),
        ...data.items.map(
          (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(i.desc, textDirection: TextDirection.ltr)),
                Expanded(child: Text('${i.qty}', textAlign: TextAlign.center)),
                Expanded(child: Text(data.money(i.rate, forPdf: false, unicodeFontLoaded: true), textAlign: TextAlign.end)),
                Expanded(child: Text(data.money(i.amount, forPdf: false, unicodeFontLoaded: true), textAlign: TextAlign.end)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return ToolResultCard(
      title: 'Summary',
      rows: [
        ('Subtotal', data.money(data.subtotal, forPdf: false, unicodeFontLoaded: true)),
        ('Tax', data.money(data.taxTotal, forPdf: false, unicodeFontLoaded: true)),
        ('Total', data.money(data.total, forPdf: false, unicodeFontLoaded: true)),
      ],
    );
  }
}

class _ClassicPreview extends StatelessWidget {
  const _ClassicPreview({required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoWidget(logoBytes: data.logoBytes),
            if (data.logoBytes != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.bizName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  if (data.bizAddr.isNotEmpty) Text(data.bizAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
                  if (data.bizGst.isNotEmpty) Text('GSTIN: ${data.bizGst}', style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Invoice #${data.invNo}', style: const TextStyle(fontWeight: FontWeight.w700)),
        Text('Bill To: ${data.custName}', style: const TextStyle(color: VStackColors.muted)),
        if (data.custAddr.isNotEmpty) Text(data.custAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
        const Divider(height: 24),
        _ItemsTable(data: data),
        const Divider(height: 24),
        _SummaryCard(data: data),
      ],
    );
  }
}

class _ModernPreview extends StatelessWidget {
  const _ModernPreview({required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VStackColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: VStackColors.accent, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoWidget(logoBytes: data.logoBytes),
              if (data.logoBytes != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.bizName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    if (data.bizAddr.isNotEmpty) Text(data.bizAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('INVOICE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  Text('#${data.invNo}', style: const TextStyle(color: VStackColors.muted)),
                  Text(data.currency.code, style: const TextStyle(color: VStackColors.accent, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bill To', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  Text(data.custName),
                  if (data.custAddr.isNotEmpty) Text(data.custAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
                ],
              ),
            ),
            if (data.bizGst.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Tax ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    Text(data.bizGst, style: const TextStyle(color: VStackColors.muted)),
                  ],
                ),
              ),
          ],
        ),
        const Divider(height: 24),
        _ItemsTable(data: data),
        const Divider(height: 24),
        _SummaryCard(data: data),
      ],
    );
  }
}

class _GstIndiaPreview extends StatelessWidget {
  const _GstIndiaPreview({required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              const Text('TAX INVOICE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              if (data.logoBytes != null) ...[
                const SizedBox(height: 8),
                _LogoWidget(logoBytes: data.logoBytes, size: 48),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(data.bizName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (data.bizAddr.isNotEmpty) Text(data.bizAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
        if (data.bizGst.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: VStackColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('GSTIN: ${data.bizGst}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bill To', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  Text(data.custName),
                  if (data.custAddr.isNotEmpty) Text(data.custAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Invoice No: ${data.invNo}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Currency: ${data.currency.code}', style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
              ],
            ),
          ],
        ),
        const Divider(height: 24),
        _ItemsTable(data: data),
        const Divider(height: 24),
        _SummaryCard(data: data),
      ],
    );
  }
}

class _GulfPreview extends StatelessWidget {
  const _GulfPreview({required this.data});

  final InvoiceData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              if (data.logoBytes != null) ...[
                _LogoWidget(logoBytes: data.logoBytes, size: 64),
                const SizedBox(height: 12),
              ],
              Text(data.bizName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              if (data.bizAddr.isNotEmpty)
                Text(data.bizAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: VStackColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice: ${data.invNo}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('To: ${data.custName}', style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
                ],
              ),
              Text(
                data.currency.code,
                style: const TextStyle(fontWeight: FontWeight.w700, color: VStackColors.accent, fontSize: 16),
              ),
            ],
          ),
        ),
        if (data.custAddr.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(data.custAddr, style: const TextStyle(color: VStackColors.muted, fontSize: 13)),
        ],
        const Divider(height: 24),
        _ItemsTable(data: data),
        const Divider(height: 24),
        _SummaryCard(data: data),
      ],
    );
  }
}
