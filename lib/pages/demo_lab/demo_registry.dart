import 'package:flutter/material.dart';
import 'package:vstackweb/models/demo.dart';
import 'package:vstackweb/pages/demo_lab/showcases/demo_coming_soon.dart';

import 'package:vstackweb/pages/demo_lab/showcases/saas_landing_template.dart'
    deferred as saas;
import 'package:vstackweb/pages/demo_lab/showcases/agency_portfolio_template.dart'
    deferred as agency;
import 'package:vstackweb/pages/demo_lab/showcases/ecommerce_storefront_template.dart'
    deferred as ecommerce;
import 'package:vstackweb/pages/demo_lab/showcases/admin_dashboard_template.dart'
    deferred as admin;
import 'package:vstackweb/pages/demo_lab/showcases/desktop_pos_template.dart'
    deferred as pos;
import 'package:vstackweb/pages/demo_lab/showcases/fintech_mobile_template.dart'
    deferred as fintech;
import 'package:vstackweb/pages/demo_lab/showcases/delivery_mobile_template.dart'
    deferred as delivery;
import 'package:vstackweb/pages/demo_lab/showcases/micro_interactions_demo.dart'
    deferred as micro;
import 'package:vstackweb/pages/demo_lab/showcases/scroll_story_demo.dart'
    deferred as scroll;
import 'package:vstackweb/pages/demo_lab/showcases/three_d_character_viewer.dart'
    deferred as three_d;

Widget buildDemoPreviewLoader(DemoEntry demo) {
  return DeferredDemoPreview(demo: demo);
}

class DeferredDemoPreview extends StatefulWidget {
  const DeferredDemoPreview({super.key, required this.demo});

  final DemoEntry demo;

  @override
  State<DeferredDemoPreview> createState() => _DeferredDemoPreviewState();
}

class _DeferredDemoPreviewState extends State<DeferredDemoPreview> {
  Widget? _preview;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final preview = await _buildPreview(widget.demo);
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<Widget> _buildPreview(DemoEntry demo) async {
    return switch (demo.interactiveType) {
      'website-saas' => await _loadDeferred(saas.loadLibrary, () => saas.SaasLandingTemplate()),
      'website-agency' => await _loadDeferred(agency.loadLibrary, () => agency.AgencyPortfolioTemplate()),
      'website-ecommerce' => await _loadDeferred(ecommerce.loadLibrary, () => ecommerce.EcommerceStorefrontTemplate()),
      'desktop-admin' => await _loadDeferred(admin.loadLibrary, () => admin.AdminDashboardTemplate()),
      'desktop-pos' => await _loadDeferred(pos.loadLibrary, () => pos.DesktopPosTemplate()),
      'mobile-fintech' => await _loadDeferred(fintech.loadLibrary, () => fintech.FintechMobileTemplate()),
      'mobile-delivery' => await _loadDeferred(delivery.loadLibrary, () => delivery.DeliveryMobileTemplate()),
      'motion-micro' => await _loadDeferred(micro.loadLibrary, () => micro.MicroInteractionsDemo()),
      'motion-scroll' => await _loadDeferred(scroll.loadLibrary, () => scroll.ScrollStoryDemo()),
      '3d-character' => await _load3d(demo, character: true),
      '3d-asset' => await _load3d(demo, character: false),
      _ => DemoComingSoon(demo: demo),
    };
  }

  Future<Widget> _loadDeferred(Future<void> Function() load, Widget Function() build) async {
    await load();
    return build();
  }

  Future<Widget> _load3d(DemoEntry demo, {required bool character}) async {
    await three_d.loadLibrary();
    final asset = demo.modelAsset ?? 'assets/demos/3d/RobotExpressive.glb';
    if (character) {
      return three_d.ThreeDCharacterViewer(modelAsset: asset);
    }
    return three_d.GameAssetShowcase(modelAsset: asset);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Failed to load preview. Please refresh.'));
    }
    if (_preview == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _preview!;
  }
}
