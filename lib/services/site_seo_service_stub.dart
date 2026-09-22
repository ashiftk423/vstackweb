import 'package:vstackweb/services/site_seo_resolver.dart';

abstract class SiteSeoService {
  void apply(SiteSeoMeta meta);
  void reset();

  /// Reports a GA4 SPA pageview for the current Flutter route.
  void trackPageView({required String path, required String title});
}

class SiteSeoServiceStub implements SiteSeoService {
  @override
  void apply(SiteSeoMeta meta) {}

  @override
  void reset() {}

  @override
  void trackPageView({required String path, required String title}) {}
}

SiteSeoService createSiteSeoService() => SiteSeoServiceStub();
