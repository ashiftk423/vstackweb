import 'package:flutter/foundation.dart';
import 'package:vstackweb/models/site_models.dart';
import 'package:vstackweb/services/vstack_content_service.dart';

class SiteContentProvider extends ChangeNotifier {
  SiteContentProvider(this._service) {
    if (_service != null) {
      _subscribe();
    } else {
      _loading = false;
    }
  }

  final VStackContentService? _service;
  SiteContent _content = SiteContent.defaults();
  bool _loading = true;
  String? _error;

  SiteContent get content => _content;
  bool get loading => _loading;
  String? get error => _error;
  VStackContentService get service {
    assert(_service != null, 'Firebase is not configured');
    return _service!;
  }

  bool get hasFirebase => _service != null;

  void _subscribe() {
    _service!.watchSiteContent().listen(
      (data) {
        _content = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      _content = await _service!.loadSiteContent();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
