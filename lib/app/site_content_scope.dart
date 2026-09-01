import 'package:flutter/material.dart';
import 'package:vstackweb/models/site_models.dart';

class SiteContentScope extends InheritedWidget {
  const SiteContentScope({
    super.key,
    required this.content,
    required super.child,
  });

  final SiteContent content;

  static SiteContent of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SiteContentScope>();
    assert(scope != null, 'SiteContentScope not found');
    return scope!.content;
  }

  static SiteContent? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SiteContentScope>()?.content;

  @override
  bool updateShouldNotify(SiteContentScope oldWidget) => content != oldWidget.content;
}
