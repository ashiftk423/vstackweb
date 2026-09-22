#!/usr/bin/env dart
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Generates static location SEO pages only.
///
/// Do NOT write HTML under web/solutions/, web/products/, or web/tools/{slug}.html —
/// GitHub Pages maps /solutions/foo → solutions/foo.html, and a self-redirect there
/// causes an infinite reload loop on shared deep links.
void main() {
  final json = File('assets/content/site_content.json').readAsStringSync();
  final data = jsonDecode(json) as Map<String, dynamic>;
  final seo = data['seo'] as Map<String, dynamic>;
  final locations = (seo['locations'] as List).cast<Map<String, dynamic>>();

  Directory('web/locations').createSync(recursive: true);

  var cityCount = 0;
  for (final loc in locations) {
    final name = loc['name'] as String;
    final slug = switch (name) {
      'Thrissur' => 'thrissur',
      'Kochi' => 'kochi',
      'Ernakulam' => 'ernakulam',
      _ => null,
    };
    if (slug != null) {
      writeCityPage(slug, loc);
      cityCount++;
    }
  }

  writeToolsHubSeo();
  deleteRouteShadowingShells();

  print('Generated $cityCount city SEO pages; removed Flutter-route-shadowing HTML shells.');
}

/// Deletes HTML that would be served for Flutter clean URLs on GitHub Pages.
void deleteRouteShadowingShells() {
  final dirs = ['web/solutions', 'web/products', 'web/tools'];
  var deleted = 0;
  for (final dirPath in dirs) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      if (!entity.path.replaceAll('\\', '/').endsWith('.html')) continue;
      entity.deleteSync();
      deleted++;
      print('Deleted ${entity.path} (was shadowing SPA route).');
    }
    // Remove empty dirs so GH Pages has nothing under solutions/products/tools.
    if (dir.listSync().isEmpty) {
      dir.deleteSync();
      print('Removed empty $dirPath/');
    }
  }
  if (deleted == 0) {
    print('No route-shadowing shells found to delete.');
  }
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
  // Path is /tools-hub-seo.html — does not shadow /tools.
  File('web/tools-hub-seo.html').writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Free Online Tools — QR, Image, PDF, Invoice &amp; More | VSTACK</title>
  <meta name="description" content="Free browser-based tools from VSTACK: QR code generator, image compressor, PDF toolkit, invoice generator, GST calculator, UTM builder and more. Privacy-first — processed locally.">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="https://vstackbusinesssolutions.com/tools">
  <meta http-equiv="refresh" content="0;url=/tools">
  <script>location.replace('/tools');</script>
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

String _escapeHtml(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
String _escapeJson(String s) =>
    s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', ' ');
