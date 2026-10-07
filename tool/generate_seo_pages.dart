#!/usr/bin/env dart
// ignore_for_file: avoid_print
import 'dart:io';

/// Writes redirect shells for legacy static pages that search engines indexed.
///
/// Each old URL instantly forwards to the matching live Flutter page (one of
/// the main solution pages, About/Careers, or home). Targets must never equal
/// the shell's own path, or GitHub Pages will serve the shell again and loop.
///
/// Do NOT write HTML under web/solutions/, web/products/, or web/tools/{slug}.html,
/// or web/team.html: GitHub Pages maps /solutions/foo → solutions/foo.html and
/// /team → team.html, which would shadow the SPA routes.
void main() {
  const redirects = <String, String>{
    'web/locations.html': '/',
    'web/locations/thrissur.html': '/',
    'web/locations/kochi.html': '/',
    'web/locations/ernakulam.html': '/',
    'web/services.html': '/',
    'web/faq.html': '/',
    'web/careers.html': '/careers',
    'web/demo-lab/index.html': '/',
    'web/tools-hub-seo.html': '/tools',
  };

  for (final entry in redirects.entries) {
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(_redirectShell(entry.value));
    print('${entry.key} → ${entry.value}');
  }

  deleteRouteShadowingShells();
  print('Wrote ${redirects.length} redirect shells.');
}

String _redirectShell(String target) {
  final absolute = 'https://vstackbusinesssolutions.com$target';
  return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VStack Business Solutions</title>
  <meta name="robots" content="noindex, follow">
  <link rel="canonical" href="$absolute">
  <meta http-equiv="refresh" content="0;url=$target">
  <script>location.replace('$target');</script>
</head>
<body style="font-family:system-ui,sans-serif;background:#06080F;color:#E8EEF8;padding:40px 20px;">
  <p>Redirecting to <a href="$target" style="color:#5B8CFF;">VStack Business Solutions</a>…</p>
</body>
</html>
''';
}

/// Deletes HTML that would be served for Flutter clean URLs on GitHub Pages.
void deleteRouteShadowingShells() {
  for (final dirPath in ['web/solutions', 'web/products', 'web/tools']) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.html')) {
        entity.deleteSync();
        print('Deleted ${entity.path} (was shadowing SPA route).');
      }
    }
    if (dir.listSync().isEmpty) dir.deleteSync();
  }
}
