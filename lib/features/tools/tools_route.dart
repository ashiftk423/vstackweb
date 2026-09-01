import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/features/tools/data/tools_registry.dart';
import 'package:vstackweb/layouts/app_shell.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

import 'package:vstackweb/features/tools/pages/device_mockup_page.dart'
    deferred as device_mockup;
import 'package:vstackweb/features/tools/pages/favicon_generator_page.dart'
    deferred as favicon_generator;
import 'package:vstackweb/features/tools/pages/gst_calculator_page.dart'
    deferred as gst_calculator;
import 'package:vstackweb/features/tools/pages/image_compressor_page.dart'
    deferred as image_compressor;
import 'package:vstackweb/features/tools/pages/image_converter_page.dart'
    deferred as image_converter;
import 'package:vstackweb/features/tools/pages/image_resizer_page.dart'
    deferred as image_resizer;
import 'package:vstackweb/features/tools/pages/invoice_generator_page.dart'
    deferred as invoice_generator;
import 'package:vstackweb/features/tools/pages/json_formatter_page.dart'
    deferred as json_formatter;
import 'package:vstackweb/features/tools/pages/pdf_tools_page.dart'
    deferred as pdf_tools;
import 'package:vstackweb/features/tools/pages/profit_margin_page.dart'
    deferred as profit_margin;
import 'package:vstackweb/features/tools/pages/qr_code_generator_page.dart'
    deferred as qr_tool;
import 'package:vstackweb/features/tools/pages/utm_builder_page.dart'
    deferred as utm_builder;

Widget buildToolPage(String slug, GoRouterState state) {
  if (!isKnownToolSlug(slug)) {
    return AppShell(
      child: Center(
        child: Text(
          'Tool not found: $slug',
          style: const TextStyle(color: VStackColors.muted),
        ),
      ),
    );
  }
  return DeferredToolPage(slug: slug, state: state);
}

bool isKnownToolSlug(String slug) => ToolsRegistry.bySlug(slug) != null;

class DeferredToolPage extends StatefulWidget {
  const DeferredToolPage({super.key, required this.slug, required this.state});

  final String slug;
  final GoRouterState state;

  @override
  State<DeferredToolPage> createState() => _DeferredToolPageState();
}

class _DeferredToolPageState extends State<DeferredToolPage> {
  Widget? _page;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final query = widget.state.uri.queryParameters;
      final page = switch (widget.slug) {
        'qr-code-generator' => await _loadQr(query['data']),
        'image-compressor' => await _loadSimple(
            image_compressor.loadLibrary,
            () => image_compressor.ImageCompressorPage(),
          ),
        'image-resizer' => await _loadSimple(
            image_resizer.loadLibrary,
            () => image_resizer.ImageResizerPage(),
          ),
        'image-converter' => await _loadSimple(
            image_converter.loadLibrary,
            () => image_converter.ImageConverterPage(),
          ),
        'pdf' => await _loadSimple(
            pdf_tools.loadLibrary,
            () => pdf_tools.PdfToolsPage(),
          ),
        'invoice-generator' => await _loadSimple(
            invoice_generator.loadLibrary,
            () => invoice_generator.InvoiceGeneratorPage(),
          ),
        'gst-calculator' => await _loadSimple(
            gst_calculator.loadLibrary,
            () => gst_calculator.GstCalculatorPage(),
          ),
        'profit-margin-calculator' => await _loadSimple(
            profit_margin.loadLibrary,
            () => profit_margin.ProfitMarginPage(),
          ),
        'utm-builder' => await _loadUtm(query['url']),
        'device-mockup' => await _loadSimple(
            device_mockup.loadLibrary,
            () => device_mockup.DeviceMockupPage(),
          ),
        'favicon-generator' => await _loadSimple(
            favicon_generator.loadLibrary,
            () => favicon_generator.FaviconGeneratorPage(),
          ),
        'json-formatter' => await _loadSimple(
            json_formatter.loadLibrary,
            () => json_formatter.JsonFormatterPage(),
          ),
        _ => null,
      };
      if (!mounted) return;
      setState(() => _page = page);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<Widget> _loadSimple(
    Future<void> Function() load,
    Widget Function() build,
  ) async {
    await load();
    return build();
  }

  Future<Widget> _loadQr(String? data) async {
    await qr_tool.loadLibrary();
    return qr_tool.QrCodeGeneratorPage(initialData: data);
  }

  Future<Widget> _loadUtm(String? url) async {
    await utm_builder.loadLibrary();
    return utm_builder.UtmBuilderPage(initialUrl: url);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppShell(
        child: Center(
          child: Text(
            'Failed to load tool. Please refresh.',
            style: const TextStyle(color: VStackColors.muted),
          ),
        ),
      );
    }
    if (_page == null) {
      return const AppShell(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return _page!;
  }
}
