import 'package:vstackweb/services/site_seo_resolver.dart';

abstract class SiteSeoService {
  void apply(SiteSeoMeta meta);
  void reset();
}

class SiteSeoServiceStub implements SiteSeoService {
  @override
  void apply(SiteSeoMeta meta) {}

  @override
  void reset() {}
}

SiteSeoService createSiteSeoService() => SiteSeoServiceStub();
