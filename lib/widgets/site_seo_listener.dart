import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/services/site_seo.dart';

/// Updates document title/meta and reports GA4 SPA pageviews on route changes.
class SiteSeoListener extends StatefulWidget {
  const SiteSeoListener({super.key, required this.child});

  final Widget child;

  @override
  State<SiteSeoListener> createState() => _SiteSeoListenerState();
}

class _SiteSeoListenerState extends State<SiteSeoListener> {
  final _seo = createSiteSeoService();
  String? _lastPath;

  void _syncSeo() {
    final path = GoRouterState.of(context).uri.path;
    if (path == _lastPath) return;
    _lastPath = path;

    final content = SiteContentScope.of(context);
    final meta = resolveSiteSeo(content, path);

    // Tool detail pages still apply their own ToolSeoService meta tags.
    final skipMeta = path.startsWith('/tools/') && path.length > '/tools/'.length;
    if (!skipMeta) {
      _seo.apply(meta);
    }

    _seo.trackPageView(
      path: path.isEmpty ? '/' : path,
      title: meta.title,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncSeo();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
