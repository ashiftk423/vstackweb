import 'dart:html' as html;

import 'package:vstackweb/features/tools/models/tool_definition.dart';
import 'package:vstackweb/features/tools/services/tool_seo_service_stub.dart';

ToolSeoService createToolSeoService() => ToolSeoServiceWeb();

class ToolSeoServiceWeb implements ToolSeoService {
  static const _baseUrl = 'https://vstackbusinesssolutions.com';
  static const _defaultTitle = 'VStack Business Solutions';
  static const _defaultDescription =
      'Build. Manage. Grow. — VStack Business Solutions. Business solutions, software, and tools.';

  @override
  void apply(ToolDefinition tool) {
    html.document.title = tool.seo.title;
    _setMeta('description', tool.seo.description);
    _setMeta('og:title', tool.seo.title, property: true);
    _setMeta('og:description', tool.seo.description, property: true);
    _setMeta('og:url', '$_baseUrl${tool.route}', property: true);
    _setMeta('twitter:title', tool.seo.title);
    _setMeta('twitter:description', tool.seo.description);
    _setCanonical('$_baseUrl${tool.route}');
  }

  @override
  void reset() {
    html.document.title = _defaultTitle;
    _setMeta('description', _defaultDescription);
    _setCanonical('$_baseUrl/');
  }

  void _setMeta(String name, String content, {bool property = false}) {
    final selector = property ? 'meta[property="$name"]' : 'meta[name="$name"]';
    final el = html.document.querySelector(selector) as html.MetaElement?;
    if (el != null) {
      el.content = content;
    }
  }

  void _setCanonical(String href) {
    final el = html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;
    if (el != null) el.href = href;
  }
}
