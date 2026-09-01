import 'package:flutter/material.dart';
import 'package:vstackweb/features/tools/models/tool_definition.dart';

abstract final class ToolsRegistry {
  static const all = <ToolDefinition>[
    qrCodeGenerator,
    imageCompressor,
    imageResizer,
    imageConverter,
    pdfToolkit,
    invoiceGenerator,
    gstCalculator,
    profitMarginCalculator,
    utmBuilder,
    deviceMockup,
    faviconGenerator,
    jsonFormatter,
  ];

  static ToolDefinition? bySlug(String slug) {
    for (final t in all) {
      if (t.slug == slug && t.isActive) return t;
    }
    return null;
  }

  static ToolDefinition? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static List<ToolDefinition> get active => all.where((t) => t.isActive).toList();

  static List<ToolDefinition> get popular =>
      active.where((t) => t.isPopular).toList();

  static List<ToolDefinition> byCategory(ToolCategory category) =>
      active.where((t) => t.category == category).toList();

  static List<ToolDefinition> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return active;
    return active.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.shortDescription.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.categoryLabel.toLowerCase().contains(q) ||
          t.keywords.any((k) => k.toLowerCase().contains(q)) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }

  static const qrCodeGenerator = ToolDefinition(
    id: 'qr-code-generator',
    name: 'QR Code Generator',
    slug: 'qr-code-generator',
    shortDescription: 'Create QR codes from links, text, contact details and more.',
    description:
        'VSTACK QR Code Generator is an online QR code generator that allows users to create QR codes from URLs, text, contact information, Wi-Fi details, UPI payments, and more. All processing happens in your browser.',
    category: ToolCategory.popular,
    icon: Icons.qr_code_2_rounded,
    keywords: ['qr', 'qrcode', 'barcode', 'wifi', 'vcard', 'upi', 'whatsapp'],
    route: '/tools/qr-code-generator',
    isPopular: true,
    seo: ToolSeoMeta(
      title: 'Free QR Code Generator Online | VSTACK',
      description:
          'Create QR codes for URLs, text, phone, email, WhatsApp, Wi-Fi, UPI, vCard and location. Free online QR generator — processed locally in your browser.',
      h1: 'QR Code Generator',
      faq: [
        ('Is this QR code generator free?', 'Yes. This tool is free to use with no login required.'),
        ('Are my QR codes stored on a server?', 'No. QR codes are generated locally in your browser.'),
      ],
    ),
    relatedToolIds: ['utm-builder', 'image-compressor'],
    tags: ['qr', 'marketing'],
    howItWorks: [
      'Choose a QR type (URL, text, contact, etc.)',
      'Enter your content and customize colors if needed',
      'Preview the QR code instantly',
      'Download as PNG',
    ],
    contextCtaLabel: 'Need a custom app with QR scanning?',
    contextCtaRoute: '/start-project',
  );

  static const imageCompressor = ToolDefinition(
    id: 'image-compressor',
    name: 'Image Compressor',
    slug: 'image-compressor',
    shortDescription: 'Compress JPG, PNG and WebP images without uploading to a server.',
    description:
        'Reduce image file sizes in your browser. Upload multiple images, adjust quality, compare before/after sizes, and download compressed files privately.',
    category: ToolCategory.image,
    icon: Icons.compress_rounded,
    keywords: ['compress', 'image', 'jpg', 'png', 'webp', 'optimize', 'reduce size'],
    route: '/tools/image-compressor',
    isPopular: true,
    seo: ToolSeoMeta(
      title: 'Free Image Compressor Online | VSTACK',
      description:
          'Compress JPG, PNG and WebP images online. Reduce file size with quality control. 100% browser-side — your images never leave your device.',
      h1: 'Image Compressor',
    ),
    relatedToolIds: ['image-resizer', 'image-converter'],
    tags: ['image'],
    howItWorks: [
      'Upload one or more images',
      'Adjust quality slider',
      'See size savings instantly',
      'Download compressed files',
    ],
    contextCtaLabel: 'Need professional digital marketing?',
    contextCtaRoute: '/solutions/digital-marketing',
  );

  static const imageResizer = ToolDefinition(
    id: 'image-resizer',
    name: 'Image Resizer',
    slug: 'image-resizer',
    shortDescription: 'Resize images with custom dimensions or social media presets.',
    description:
        'Resize images for Instagram, Facebook, LinkedIn, YouTube, WhatsApp and more. Lock aspect ratio, choose output format, and download locally.',
    category: ToolCategory.image,
    icon: Icons.photo_size_select_large_rounded,
    keywords: ['resize', 'image', 'instagram', 'youtube', 'thumbnail', 'social'],
    route: '/tools/image-resizer',
    seo: ToolSeoMeta(
      title: 'Free Image Resizer Online | VSTACK',
      description:
          'Resize images online with social media presets or custom dimensions. Instagram, Facebook, LinkedIn, YouTube and more.',
      h1: 'Image Resizer',
    ),
    relatedToolIds: ['image-compressor', 'image-converter'],
    tags: ['image', 'marketing'],
    howItWorks: [
      'Upload an image',
      'Pick a preset or enter custom size',
      'Preview the result',
      'Download resized image',
    ],
  );

  static const imageConverter = ToolDefinition(
    id: 'image-converter',
    name: 'Image Converter',
    slug: 'image-converter',
    shortDescription: 'Convert between JPG, PNG and WebP formats.',
    description:
        'Convert images between JPG, PNG and WebP in your browser. Batch convert multiple files with no server upload.',
    category: ToolCategory.image,
    icon: Icons.swap_horiz_rounded,
    keywords: ['convert', 'jpg', 'png', 'webp', 'format'],
    route: '/tools/image-converter',
    seo: ToolSeoMeta(
      title: 'Free Image Format Converter Online | VSTACK',
      description: 'Convert JPG, PNG and WebP images online. Browser-side conversion for privacy.',
      h1: 'Image Format Converter',
    ),
    relatedToolIds: ['image-compressor', 'image-resizer'],
    tags: ['image'],
    howItWorks: [
      'Upload images',
      'Select output format',
      'Convert locally',
      'Download converted files',
    ],
  );

  static const pdfToolkit = ToolDefinition(
    id: 'pdf-toolkit',
    name: 'PDF Toolkit',
    slug: 'pdf',
    shortDescription: 'Merge, split, compress and convert PDFs in your browser.',
    description:
        'All-in-one PDF tools: merge, split, compress, rotate, PDF to image, and image to PDF. Processed locally in your browser using pdf-lib.',
    category: ToolCategory.pdf,
    icon: Icons.picture_as_pdf_rounded,
    keywords: ['pdf', 'merge', 'split', 'compress', 'rotate', 'convert'],
    route: '/tools/pdf',
    seo: ToolSeoMeta(
      title: 'Free PDF Tools Online — Merge, Split, Compress | VSTACK',
      description:
          'Merge, split, compress, rotate PDFs and convert PDF to image or image to PDF. Browser-side processing.',
      h1: 'PDF Toolkit',
    ),
    relatedToolIds: ['image-converter', 'invoice-generator'],
    tags: ['pdf'],
    howItWorks: [
      'Choose a PDF operation',
      'Upload your file(s)',
      'Process locally in browser',
      'Download the result',
    ],
  );

  static const invoiceGenerator = ToolDefinition(
    id: 'invoice-generator',
    name: 'Invoice Generator',
    slug: 'invoice-generator',
    shortDescription: 'Create professional invoices with GST and download as PDF.',
    description:
        'Generate professional invoices with business details, line items, tax calculations, and PDF download. All data stays in your browser.',
    category: ToolCategory.business,
    icon: Icons.receipt_long_rounded,
    keywords: ['invoice', 'bill', 'gst', 'pdf', 'business'],
    route: '/tools/invoice-generator',
    isPopular: true,
    seo: ToolSeoMeta(
      title: 'Free Invoice Generator | VSTACK',
      description:
          'Create professional invoices with GST support. Preview and download PDF invoices online — free, no login.',
      h1: 'Invoice Generator',
    ),
    relatedToolIds: ['gst-calculator', 'profit-margin-calculator'],
    tags: ['business', 'invoice'],
    howItWorks: [
      'Enter business and customer details',
      'Add line items with tax',
      'Preview the invoice',
      'Download as PDF',
    ],
    contextCtaLabel: 'Need complete billing & business management?',
    contextCtaRoute: '/products/quickrent',
  );

  static const gstCalculator = ToolDefinition(
    id: 'gst-calculator',
    name: 'GST Calculator',
    slug: 'gst-calculator',
    shortDescription: 'Calculate GST inclusive or exclusive amounts for India.',
    description:
        'Quick GST calculator for India. Calculate base amount, GST, CGST, SGST and total with inclusive or exclusive modes.',
    category: ToolCategory.business,
    icon: Icons.calculate_rounded,
    keywords: ['gst', 'tax', 'india', 'cgst', 'sgst', 'calculator'],
    route: '/tools/gst-calculator',
    isPopular: true,
    seo: ToolSeoMeta(
      title: 'GST Calculator Online | VSTACK',
      description:
          'Free GST calculator for India. Calculate inclusive and exclusive GST at 5%, 12%, 18%, 28% or custom rate.',
      h1: 'GST Calculator',
    ),
    relatedToolIds: ['profit-margin-calculator', 'invoice-generator'],
    tags: ['business', 'gst'],
    howItWorks: [
      'Enter amount',
      'Choose inclusive or exclusive',
      'Select GST rate',
      'View breakdown instantly',
    ],
  );

  static const profitMarginCalculator = ToolDefinition(
    id: 'profit-margin-calculator',
    name: 'Profit & Margin Calculator',
    slug: 'profit-margin-calculator',
    shortDescription: 'Calculate profit, margin and markup percentages.',
    description:
        'Calculate profit per unit, total profit, profit percentage, margin and markup from cost and selling price.',
    category: ToolCategory.business,
    icon: Icons.trending_up_rounded,
    keywords: ['profit', 'margin', 'markup', 'business', 'calculator'],
    route: '/tools/profit-margin-calculator',
    seo: ToolSeoMeta(
      title: 'Profit & Margin Calculator Online | VSTACK',
      description: 'Calculate profit, margin and markup from cost and selling price. Free business calculator.',
      h1: 'Profit & Margin Calculator',
    ),
    relatedToolIds: ['gst-calculator', 'invoice-generator'],
    tags: ['business'],
    howItWorks: [
      'Enter cost and selling price',
      'Optionally enter quantity',
      'See profit, margin and markup',
    ],
  );

  static const utmBuilder = ToolDefinition(
    id: 'utm-builder',
    name: 'UTM Builder',
    slug: 'utm-builder',
    shortDescription: 'Build campaign tracking URLs with UTM parameters.',
    description:
        'Create UTM tracking links for digital marketing campaigns. Copy, open, or generate a QR code for your campaign URL.',
    category: ToolCategory.marketing,
    icon: Icons.link_rounded,
    keywords: ['utm', 'tracking', 'campaign', 'marketing', 'url'],
    route: '/tools/utm-builder',
    seo: ToolSeoMeta(
      title: 'UTM Builder — Campaign URL Generator | VSTACK',
      description:
          'Build UTM tracking URLs for marketing campaigns. Copy, open or generate QR codes for campaign links.',
      h1: 'UTM Builder',
    ),
    relatedToolIds: ['qr-code-generator'],
    tags: ['marketing', 'utm'],
    howItWorks: [
      'Enter website URL and campaign details',
      'Generated tracking URL appears instantly',
      'Copy or open the URL',
      'Generate QR code for the link',
    ],
    contextCtaLabel: 'Need help managing digital campaigns?',
    contextCtaRoute: '/solutions/digital-marketing',
  );

  static const deviceMockup = ToolDefinition(
    id: 'device-mockup',
    name: 'Device Mockup Generator',
    slug: 'device-mockup',
    shortDescription: 'Place screenshots inside phone, tablet or laptop frames.',
    description:
        'Upload a website or app screenshot and generate professional device mockups for presentations and marketing.',
    category: ToolCategory.design,
    icon: Icons.phone_iphone_rounded,
    keywords: ['mockup', 'device', 'screenshot', 'iphone', 'laptop'],
    route: '/tools/device-mockup',
    seo: ToolSeoMeta(
      title: 'Device Mockup Generator Online | VSTACK',
      description: 'Create phone, tablet and laptop mockups from screenshots. Free browser-based mockup tool.',
      h1: 'Device Mockup Generator',
    ),
    relatedToolIds: ['image-resizer', 'favicon-generator'],
    tags: ['design', 'mockup'],
    howItWorks: [
      'Upload your screenshot',
      'Select a device frame',
      'Adjust padding and background',
      'Download mockup as PNG',
    ],
    contextCtaLabel: 'Need a website or mobile app?',
    contextCtaRoute: '/start-project',
  );

  static const faviconGenerator = ToolDefinition(
    id: 'favicon-generator',
    name: 'Favicon Generator',
    slug: 'favicon-generator',
    shortDescription: 'Generate favicon and app icon sizes from your logo.',
    description:
        'Upload a logo and generate standard favicon and app icon sizes (16, 32, 48, 180, 192, 512) for web and mobile.',
    category: ToolCategory.developer,
    icon: Icons.web_rounded,
    keywords: ['favicon', 'icon', 'app icon', 'logo', 'pwa'],
    route: '/tools/favicon-generator',
    seo: ToolSeoMeta(
      title: 'Favicon & App Icon Generator Online | VSTACK',
      description: 'Generate favicon and app icon sizes from your logo. Download PNG icons for web and mobile.',
      h1: 'Favicon Generator',
    ),
    relatedToolIds: ['image-resizer', 'device-mockup'],
    tags: ['developer', 'design'],
    howItWorks: [
      'Upload your logo or image',
      'Preview generated icon sizes',
      'Download individual icons or all sizes',
    ],
  );

  static const jsonFormatter = ToolDefinition(
    id: 'json-formatter',
    name: 'JSON Formatter',
    slug: 'json-formatter',
    shortDescription: 'Format, minify and validate JSON locally.',
    description:
        'Format, minify and validate JSON in your browser. Your data never leaves your device.',
    category: ToolCategory.developer,
    icon: Icons.data_object_rounded,
    keywords: ['json', 'format', 'validate', 'minify', 'developer'],
    route: '/tools/json-formatter',
    seo: ToolSeoMeta(
      title: 'JSON Formatter & Validator Online | VSTACK',
      description: 'Format, minify and validate JSON online. 100% local processing — no data sent to servers.',
      h1: 'JSON Formatter',
    ),
    relatedToolIds: ['utm-builder'],
    tags: ['developer', 'json'],
    howItWorks: [
      'Paste your JSON',
      'Format, minify or validate',
      'Copy the result',
    ],
  );
}
