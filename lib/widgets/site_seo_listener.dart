import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/app/site_content_scope.dart';
import 'package:vstackweb/services/site_seo.dart';

/// Updates document title and meta tags when the route changes (web only).
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

    if (path.startsWith('/tools/') && path.length > '/tools/'.length) return;

    final content = SiteContentScope.of(context);
    final meta = resolveSiteSeo(content, path);
    _seo.apply(meta);
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
