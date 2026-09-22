#!/usr/bin/env dart
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final json = File('assets/content/site_content.json').readAsStringSync();
  final data = jsonDecode(json) as Map<String, dynamic>;
  final solutions = (data['solutions'] as List).cast<Map<String, dynamic>>();
  final products = (data['products'] as List).cast<Map<String, dynamic>>();
  final seo = data['seo'] as Map<String, dynamic>;
  final locations = (seo['locations'] as List).cast<Map<String, dynamic>>();

  Directory('web/solutions').createSync(recursive: true);
  Directory('web/products').createSync(recursive: true);
  Directory('web/locations').createSync(recursive: true);

  for (final s in solutions) {
    writeSolutionPage(s);
  }
  for (final p in products) {
    writeProductPage(p);
  }
  for (final loc in locations) {
    final name = loc['name'] as String;
    final slug = switch (name) {
      'Thrissur' => 'thrissur',
      'Kochi' => 'kochi',
      'Ernakulam' => 'ernakulam',
      _ => null,
    };
    if (slug != null) writeCityPage(slug, loc);
  }

  writeToolRedirectShells();
  writeToolsHubSeo();

  // Remove directory index that hijacks /tools Flutter route.
  final toolsIndex = File('web/tools/index.html');
  if (toolsIndex.existsSync()) {
    toolsIndex.deleteSync();
    print('Deleted web/tools/index.html (was shadowing /tools SPA).');
  }

  print(
    'Generated ${solutions.length} solution, ${products.length} product, '
    'city SEO pages, and tool redirect shells.',
  );
}

String _redirectHead(String cleanPath) => '''
  <link rel="canonical" href="https://vstackbusinesssolutions.com$cleanPath">
  <meta http-equiv="refresh" content="0;url=$cleanPath">
  <script>location.replace('$cleanPath');</script>''';

void writeSolutionPage(Map<String, dynamic> s) {
  final slug = s['slug'] as String;
  final title = s['title'] as String;
  final desc = s['shortDescription'] as String;
  final hero = s['heroSubtitle'] as String;
  final features = (s['features'] as List).cast<String>();
  final cleanPath = '/solutions/$slug';
  final canonical = 'https://vstackbusinesssolutions.com$cleanPath';
  final path = 'web/solutions/$slug.html';
  final featureLis = features.map((f) => '        <li>${_escapeHtml(f)}</li>').join('\n');
  final schemaDesc = _escapeJson(hero);
  final areaServed = slug == 'digital-marketing'
      ? '["Thrissur", "Kochi", "Ernakulam", "Kerala", "India"]'
      : '["Thrissur", "Kochi", "Ernakulam", "Kerala", "India"]';

  File(path).writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_escapeHtml(title)} | VStack Business Solutions — Kerala &amp; India</title>
  <meta name="description" content="${_escapeAttr('$desc — VStack Business Solutions, Thrissur, Ernakulam, Kochi & Kerala. Contact: vstackitsolutions@gmail.com · +91 81568 25205')}">
  <meta name="robots" content="index, follow">
${_redirectHead(cleanPath)}
  <link rel="icon" type="image/png" href="../favicon.png"/>
  <meta property="og:title" content="${_escapeAttr('$title | VStack Business Solutions')}">
  <meta property="og:description" content="${_escapeAttr(desc)}">
  <meta property="og:url" content="$canonical">
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; font-family: system-ui, sans-serif; background: #06080F; color: #E8EEF8; line-height: 1.55; }
    main { max-width: 860px; margin: 0 auto; padding: 40px 20px 64px; }
    a { color: #5B8CFF; }
    .badge { color: #5B8CFF; font-size: 12px; letter-spacing: 1.5px; text-transform: uppercase; }
    h1 { font-size: 2rem; margin: 8px 0 12px; }
    .lead { color: #9AA6C0; margin-bottom: 24px; }
    section { background: #0E1424; border: 1px solid #1E2A44; border-radius: 16px; padding: 22px 24px; margin-bottom: 18px; }
    ul { margin: 0; padding-left: 20px; color: #9AA6C0; }
    li { margin-bottom: 6px; }
    .cta { display: inline-block; margin-top: 20px; padding: 12px 20px; background: #3B6EF5; color: #fff; text-decoration: none; border-radius: 10px; font-weight: 600; }
    .nav { margin-bottom: 24px; font-size: 13px; color: #9AA6C0; }
  </style>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Service",
    "name": "${_escapeJson(title)}",
    "description": "$schemaDesc",
    "url": "$canonical",
    "provider": {
      "@type": "Organization",
      "name": "VStack Business Solutions",
      "url": "https://vstackbusinesssolutions.com/"
    },
    "areaServed": $areaServed
  }
  </script>
</head>
<body>
  <main>
    <p class="nav"><a href="/">Home</a> · <a href="/solutions">Solutions</a> · <a href="/contact">Contact</a></p>
    <p class="badge">Solution</p>
    <h1>${_escapeHtml(title)}</h1>
    <p class="lead">${_escapeHtml(hero)}</p>
    <section>
      <ul>
$featureLis
      </ul>
    </section>
    <p><a class="cta" href="$cleanPath">Continue to ${_escapeHtml(title)} →</a></p>
    <p style="color:#9AA6C0;font-size:13px;">If you are not redirected automatically, use the button above.</p>
  </main>
</body>
</html>
''');
}

void writeProductPage(Map<String, dynamic> p) {
  final slug = p['slug'] as String;
  final name = p['name'] as String;
  final desc = p['description'] as String;
  final tagline = p['tagline'] as String;
  final features = (p['features'] as List).cast<String>();
  final cleanPath = '/products/$slug';
  final canonical = 'https://vstackbusinesssolutions.com$cleanPath';
  final path = 'web/products/$slug.html';
  final featureLis = features.map((f) => '        <li>${_escapeHtml(f)}</li>').join('\n');

  File(path).writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${_escapeHtml(name)} — ${_escapeHtml(p['category'] as String)} | VStack Business Solutions</title>
  <meta name="description" content="${_escapeAttr('$tagline $desc')}">
  <meta name="robots" content="index, follow">
${_redirectHead(cleanPath)}
  <link rel="icon" type="image/png" href="../favicon.png"/>
  <meta property="og:title" content="${_escapeAttr('$name | VStack Business Solutions')}">
  <meta property="og:description" content="${_escapeAttr(tagline)}">
  <meta property="og:url" content="$canonical">
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; font-family: system-ui, sans-serif; background: #06080F; color: #E8EEF8; line-height: 1.55; }
    main { max-width: 860px; margin: 0 auto; padding: 40px 20px 64px; }
    a { color: #5B8CFF; }
    .badge { color: #5B8CFF; font-size: 12px; letter-spacing: 1.5px; text-transform: uppercase; }
    h1 { font-size: 2rem; margin: 8px 0 12px; }
    .lead { color: #9AA6C0; margin-bottom: 24px; }
    section { background: #0E1424; border: 1px solid #1E2A44; border-radius: 16px; padding: 22px 24px; margin-bottom: 18px; }
    ul { margin: 0; padding-left: 20px; color: #9AA6C0; }
    .cta { display: inline-block; margin-top: 20px; padding: 12px 20px; background: #3B6EF5; color: #fff; text-decoration: none; border-radius: 10px; font-weight: 600; }
    .nav { margin-bottom: 24px; font-size: 13px; color: #9AA6C0; }
  </style>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Product",
    "name": "${_escapeJson(name)}",
    "description": "${_escapeJson(desc)}",
    "url": "$canonical",
    "brand": { "@type": "Organization", "name": "VStack Business Solutions" },
    "category": "${_escapeJson(p['category'] as String)}"
  }
  </script>
</head>
<body>
  <main>
    <p class="nav"><a href="/">Home</a> · <a href="/products">Products</a></p>
    <p class="badge">VStack Product</p>
    <h1>${_escapeHtml(name)}</h1>
    <p class="lead">${_escapeHtml(tagline)}</p>
    <section><p style="color:#9AA6C0;margin:0 0 12px;">${_escapeHtml(desc)}</p><ul>
$featureLis
    </ul></section>
    <p><a class="cta" href="$cleanPath">Continue to ${_escapeHtml(name)} →</a></p>
  </main>
</body>
</html>
''');
}

void writeCityPage(String slug, Map<String, dynamic> loc) {
  final name = loc['name'] as String;
  final region = loc['region'] as String;
  final highlights = (loc['highlights'] as List).cast<String>();
  final canonical = 'https://vstackbusinesssolutions.com/locations/$slug.html';
  final lis = highlights.map((h) => '        <li>${_escapeHtml(h)}</li>').join('\n');
  final aliasNote = name == 'Ernakulam'
      ? '<p class="lead">Ernakulam / Kochi metro — VStack serves shops, offices, and growing brands across Ernakulam district and Greater Kochi.</p>'
      : '';

  File('web/locations/$slug.html').writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Best Software &amp; Digital Marketing Company in ${_escapeHtml(name)} | VStack</title>
  <meta name="description" content="VStack Business Solutions — affordable software, billing, POS, Flutter apps, and digital marketing in ${_escapeHtml(name)}, $region. Best local business technology partner. vstackitsolutions@gmail.com · +91 81568 25205">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="$canonical">
  <link rel="icon" type="image/png" href="../favicon.png"/>
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; font-family: system-ui, sans-serif; background: #06080F; color: #E8EEF8; line-height: 1.55; }
    main { max-width: 860px; margin: 0 auto; padding: 40px 20px 64px; }
    a { color: #5B8CFF; }
    .badge { color: #5B8CFF; font-size: 12px; letter-spacing: 1.5px; text-transform: uppercase; }
    h1 { font-size: 2rem; margin: 8px 0 12px; }
    .lead { color: #9AA6C0; margin-bottom: 24px; }
    section { background: #0E1424; border: 1px solid #1E2A44; border-radius: 16px; padding: 22px 24px; margin-bottom: 18px; }
    ul { margin: 0; padding-left: 20px; color: #9AA6C0; }
    .cta { display: inline-block; margin-top: 12px; margin-right: 12px; padding: 12px 20px; background: #3B6EF5; color: #fff; text-decoration: none; border-radius: 10px; font-weight: 600; }
    .nav { margin-bottom: 24px; font-size: 13px; color: #9AA6C0; }
  </style>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "LocalBusiness",
    "name": "VStack Business Solutions — ${_escapeJson(name)}",
    "description": "Software and digital marketing company serving ${_escapeJson(name)}, $region",
    "url": "https://vstackbusinesssolutions.com/",
    "email": "vstackitsolutions@gmail.com",
    "telephone": "+918156825205",
    "address": { "@type": "PostalAddress", "addressLocality": "${_escapeJson(name)}", "addressRegion": "Kerala", "addressCountry": "IN" },
    "areaServed": "${_escapeJson(name)}"
  }
  </script>
</head>
<body>
  <main>
    <p class="nav"><a href="/">Home</a> · <a href="/locations.html">All locations</a> · <a href="/solutions">Solutions</a> · <a href="/contact">Contact</a></p>
    <p class="badge">${_escapeHtml(name)} · ${_escapeHtml(region)}</p>
    <h1>Best software &amp; digital marketing in ${_escapeHtml(name)}</h1>
    <p class="lead">VStack Business Solutions delivers affordable custom software, billing &amp; POS, Flutter apps, websites, business-led digital marketing, hardware, and CCTV in ${_escapeHtml(name)} and across Kerala.</p>
    $aliasNote
    <section><ul>
$lis
    </ul></section>
    <a class="cta" href="/solutions/digital-marketing">Digital Marketing →</a>
    <a class="cta" href="/contact">Contact VStack in ${_escapeHtml(name)} →</a>
  </main>
</body>
</html>
''');
}

void writeToolsHubSeo() {
  File('web/tools-hub-seo.html').writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Free Online Tools — QR, Image, PDF, Invoice &amp; More | VSTACK</title>
  <meta name="description" content="Free browser-based tools from VSTACK: QR code generator, image compressor, PDF toolkit, invoice generator, GST calculator, UTM builder and more. Privacy-first — processed locally.">
  <meta name="robots" content="index, follow">
${_redirectHead('/tools')}
  <link rel="icon" type="image/png" href="favicon.png"/>
</head>
<body style="font-family:system-ui,sans-serif;background:#06080F;color:#E8EEF8;padding:40px 20px;">
  <main style="max-width:720px;margin:0 auto;">
    <h1>Free Online Tools — VSTACK</h1>
    <p>Redirecting to the full tools hub…</p>
    <p><a href="/tools" style="color:#5B8CFF;">Open VSTACK Tools →</a></p>
  </main>
</body>
</html>
''');
}

void writeToolRedirectShells() {
  Directory('web/tools').createSync(recursive: true);
  final tools = <(String, String, String)>[
    ('qr-code-generator', 'QR Code Generator', 'Create QR codes online for free.'),
    ('image-compressor', 'Image Compressor', 'Compress images in your browser.'),
    ('video-compressor', 'Video Compressor', 'Compress videos in your browser with ffmpeg.wasm.'),
    ('image-resizer', 'Image Resizer', 'Resize images online.'),
    ('image-converter', 'Image Converter', 'Convert image formats online.'),
    ('pdf', 'PDF Toolkit', 'Merge, split, and convert PDFs locally.'),
    ('invoice-generator', 'Invoice Generator', 'Create professional invoices with GST support.'),
    ('gst-calculator', 'GST Calculator', 'Calculate GST amounts quickly.'),
    ('profit-margin-calculator', 'Profit & Margin Calculator', 'Calculate profit and margins.'),
    ('utm-builder', 'UTM Builder', 'Build UTM campaign URLs.'),
    ('device-mockup', 'Device Mockup Generator', 'Create device mockups.'),
    ('favicon-generator', 'Favicon Generator', 'Generate favicons from your logo.'),
    ('json-formatter', 'JSON Formatter', 'Format and validate JSON.'),
  ];

  for (final t in tools) {
    final (slug, name, desc) = t;
    final cleanPath = '/tools/$slug';
    File('web/tools/$slug.html').writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$name | VSTACK</title>
  <meta name="description" content="$desc">
  <meta name="robots" content="index, follow">
${_redirectHead(cleanPath)}
  <link rel="icon" type="image/png" href="../favicon.png"/>
</head>
<body style="font-family:system-ui,sans-serif;background:#06080F;color:#E8EEF8;padding:40px 20px;">
  <main style="max-width:720px;margin:0 auto;">
    <h1>$name</h1>
    <p>$desc</p>
    <p><a href="$cleanPath" style="color:#5B8CFF;">Continue to tool →</a></p>
    <p><a href="/tools" style="color:#5B8CFF;">Browse all VSTACK tools →</a></p>
  </main>
</body>
</html>
''');
  }
}

String _escapeAttr(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');
String _escapeHtml(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
String _escapeJson(String s) =>
    s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', ' ');
