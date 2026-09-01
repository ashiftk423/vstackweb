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

  for (final s in solutions) {
    writeSolutionPage(s);
  }
  for (final p in products) {
    writeProductPage(p);
  }
  for (final loc in locations) {
    final name = loc['name'] as String;
    if (name == 'Thrissur' || name == 'Kochi') {
      writeCityPage(name.toLowerCase(), loc);
    }
  }
  print('Generated ${solutions.length} solution, ${products.length} product, and city SEO pages.');
}

void writeSolutionPage(Map<String, dynamic> s) {
  final slug = s['slug'] as String;
  final title = s['title'] as String;
  final desc = s['shortDescription'] as String;
  final hero = s['heroSubtitle'] as String;
  final features = (s['features'] as List).cast<String>();
  final canonical = 'https://vstackbusinesssolutions.com/solutions/$slug';
  final path = 'web/solutions/$slug.html';
  final featureLis = features.map((f) => '        <li>$f</li>').join('\n');
  final schemaDesc = _escapeJson(hero);

  File(path).writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title | VStack Business Solutions — Kerala &amp; India</title>
  <meta name="description" content="${_escapeAttr('$desc — VStack Business Solutions, Kerala & India. Contact: vstackitsolutions@gmail.com · +91 81568 25205')}">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="$canonical">
  <link rel="icon" type="image/png" href="../favicon.png"/>
  <meta property="og:title" content="$title | VStack Business Solutions">
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
    "areaServed": ["Thrissur", "Kochi", "Kerala", "India"]
  }
  </script>
</head>
<body>
  <main>
    <p class="nav"><a href="https://vstackbusinesssolutions.com/">Home</a> · <a href="../services.html">Services</a> · <a href="../faq.html">FAQ</a></p>
    <p class="badge">Solution</p>
    <h1>$title</h1>
    <p class="lead">$hero</p>
    <section>
      <ul>
$featureLis
      </ul>
    </section>
    <a class="cta" href="https://vstackbusinesssolutions.com/solutions/$slug">View $title on VStack →</a>
    <a class="cta" href="https://vstackbusinesssolutions.com/start-project" style="margin-left:12px;background:#1E2A44;">Start a Project</a>
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
  final canonical = 'https://vstackbusinesssolutions.com/products/$slug';
  final path = 'web/products/$slug.html';
  final featureLis = features.map((f) => '        <li>$f</li>').join('\n');

  File(path).writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$name — ${p['category']} | VStack Business Solutions</title>
  <meta name="description" content="${_escapeAttr('$tagline $desc')}">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="$canonical">
  <link rel="icon" type="image/png" href="../favicon.png"/>
  <meta property="og:title" content="$name | VStack Business Solutions">
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
    <p class="nav"><a href="https://vstackbusinesssolutions.com/">Home</a> · <a href="https://vstackbusinesssolutions.com/products">Products</a></p>
    <p class="badge">VStack Product</p>
    <h1>$name</h1>
    <p class="lead">$tagline</p>
    <section><p style="color:#9AA6C0;margin:0 0 12px;">$desc</p><ul>
$featureLis
    </ul></section>
    <a class="cta" href="https://vstackbusinesssolutions.com/products/$slug">View $name →</a>
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
  final lis = highlights.map((h) => '        <li>$h</li>').join('\n');
  final titleName = name == 'Thrissur' ? 'Thrissur' : name;

  File('web/locations/$slug.html').writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Best Software Company in $titleName | VStack Business Solutions</title>
  <meta name="description" content="VStack Business Solutions — best software company in $titleName, $region. Custom software, billing, POS, Flutter apps, digital marketing, CCTV &amp; IT. vstackitsolutions@gmail.com · +91 81568 25205">
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
    .cta { display: inline-block; margin-top: 20px; padding: 12px 20px; background: #3B6EF5; color: #fff; text-decoration: none; border-radius: 10px; font-weight: 600; }
    .nav { margin-bottom: 24px; font-size: 13px; color: #9AA6C0; }
  </style>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "LocalBusiness",
    "name": "VStack Business Solutions — $titleName",
    "description": "Software company serving $titleName, $region",
    "url": "https://vstackbusinesssolutions.com/",
    "email": "vstackitsolutions@gmail.com",
    "telephone": "+918156825205",
    "address": { "@type": "PostalAddress", "addressLocality": "$titleName", "addressRegion": "Kerala", "addressCountry": "IN" },
    "areaServed": "$titleName"
  }
  </script>
</head>
<body>
  <main>
    <p class="nav"><a href="https://vstackbusinesssolutions.com/">Home</a> · <a href="../locations.html">All locations</a> · <a href="../services.html">Services</a></p>
    <p class="badge">$titleName · $region</p>
    <h1>Best software company in $titleName</h1>
    <p class="lead">VStack Business Solutions (We Stack) delivers affordable custom software, billing &amp; POS, Flutter apps, websites, digital marketing, hardware, and CCTV in $titleName and across Kerala.</p>
    <section><ul>
$lis
    </ul></section>
    <a class="cta" href="https://vstackbusinesssolutions.com/contact">Contact VStack in $titleName →</a>
  </main>
</body>
</html>
''');
}

String _escapeAttr(String s) => s.replaceAll('&', '&amp;').replaceAll('"', '&quot;');
String _escapeJson(String s) => s.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', ' ');
