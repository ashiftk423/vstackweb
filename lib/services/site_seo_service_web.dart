import 'dart:html' as html;

import 'package:vstackweb/services/site_seo_resolver.dart';
import 'package:vstackweb/services/site_seo_service_stub.dart';

SiteSeoService createSiteSeoService() => SiteSeoServiceWeb();

class SiteSeoServiceWeb implements SiteSeoService {
  @override
  void apply(SiteSeoMeta meta) {
    html.document.title = meta.title;
    _setMeta('description', meta.description);
    _setMeta('og:title', meta.title, property: true);
    _setMeta('og:description', meta.description, property: true);
    _setMeta('og:url', '${SiteSeoDefaults.baseUrl}${meta.canonicalPath}', property: true);
    _setMeta('twitter:title', meta.title);
    _setMeta('twitter:description', meta.description);
    _setCanonical('${SiteSeoDefaults.baseUrl}${meta.canonicalPath}');
  }

  @override
  void reset() {
    html.document.title = SiteSeoDefaults.defaultTitle;
    _setMeta('description', SiteSeoDefaults.defaultDescription);
    _setCanonical('${SiteSeoDefaults.baseUrl}/');
  }

  void _setMeta(String name, String content, {bool property = false}) {
    final selector = property ? 'meta[property="$name"]' : 'meta[name="$name"]';
    final el = html.document.querySelector(selector) as html.MetaElement?;
    if (el != null) el.content = content;
  }

  void _setCanonical(String href) {
    final el = html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;
    if (el != null) el.href = href;
  }
}
