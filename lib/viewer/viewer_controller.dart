import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme.dart';

/// What the user opened in the 3D view.
class ViewerSelection {
  const ViewerSelection({
    required this.key,
    required this.name,
    required this.layer,
    required this.whole,
    this.partId,
  });

  /// Text key, for example "heart".
  final String key;

  /// Anatomical name of the piece that was tapped (English).
  final String name;
  final String layer;

  /// True when the whole organ or bone group is selected, false when a single
  /// piece (one muscle, one artery, ...) is selected.
  final bool whole;
  final String? partId;
}

/// Talks to the 3D viewer page (assets/web/viewer.js) inside the WebView.
class ViewerController extends ChangeNotifier {
  ViewerController({
    required this.onSelect,
    required this.onClear,
    required this.onLayers,
  });

  final void Function(ViewerSelection selection) onSelect;
  final VoidCallback onClear;
  final void Function(Map<String, bool> layers) onLayers;

  WebViewController? _web;
  WebViewController? get web => _web;

  bool _booted = false;
  bool _ready = false;
  double _progress = 0;
  String? _error;

  String _sex = 'male';
  bool _light = false;
  Map<String, bool> _layers = const {};

  bool get ready => _ready;
  double get progress => _progress;

  /// "webgl2", "load" or "context" when something went wrong.
  String? get error => _error;

  Future<void> open(
    Uri page, {
    required String sex,
    required Map<String, bool> layers,
  }) async {
    _sex = sex;
    _layers = layers;
    _light = AnatomoColors.isLight;
    final origin = '${page.scheme}://${page.host}:${page.port}';
    final web = WebViewController();
    _web = web;
    await web.setJavaScriptMode(JavaScriptMode.unrestricted);
    await web.setBackgroundColor(AnatomoColors.stage);
    await web.addJavaScriptChannel(
      'AnatomoBridge',
      onMessageReceived: (message) => _onMessage(message.message),
    );
    await web.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) => request.url.startsWith(origin)
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) _fail('load');
        },
      ),
    );
    notifyListeners();
    await web.loadRequest(page);
  }

  /// Loads the page again, for example after an error.
  Future<void> reload() async {
    _error = null;
    _ready = false;
    _booted = false;
    _progress = 0;
    notifyListeners();
    await _web?.reload();
  }

  void _fail(String code) {
    _error = code;
    notifyListeners();
  }

  void _onMessage(String raw) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (msg['type']) {
      case 'boot':
        _booted = true;
        _run('anatomo.setTheme(${jsonEncode(_light ? 'light' : 'dark')}); '
            'anatomo.setLayers(${jsonEncode(_layers)}); '
            'anatomo.load(${jsonEncode(_sex)});');
      case 'progress':
        _ready = false;
        _progress = (msg['value'] as num?)?.toDouble() ?? 0;
        notifyListeners();
      case 'ready':
        _ready = true;
        _progress = 1;
        _error = null;
        notifyListeners();
      case 'select':
        onSelect(
          ViewerSelection(
            key: '${msg['key']}',
            name: '${msg['name'] ?? ''}',
            layer: '${msg['layer'] ?? ''}',
            whole: msg['whole'] == true,
            partId: msg['partId'] as String?,
          ),
        );
      case 'clear':
        onClear();
      case 'layers':
        final map = msg['layers'];
        if (map is Map) {
          _layers = map.map((k, v) => MapEntry('$k', v == true));
          onLayers(_layers);
        }
      case 'error':
        _fail('${msg['code'] ?? 'load'}');
    }
  }

  Future<void> _run(String js) async {
    final web = _web;
    if (web == null || !_booted) return;
    try {
      await web.runJavaScript(js);
    } catch (_) {
      // The page is reloading; the next boot sends the current state again.
    }
  }

  void loadBody(String sex) {
    if (sex == _sex && (_ready || !_booted)) {
      _sex = sex;
      return;
    }
    _sex = sex;
    _ready = false;
    _progress = 0;
    notifyListeners();
    _run('anatomo.load(${jsonEncode(sex)})');
  }

  /// Called on every rebuild; does nothing unless the mode really changed.
  void syncTheme() {
    final light = AnatomoColors.isLight;
    if (light == _light) return;
    _light = light;
    _web?.setBackgroundColor(AnatomoColors.stage);
    _run('anatomo.setTheme(${jsonEncode(light ? 'light' : 'dark')})');
  }

  void setLayers(Map<String, bool> layers) {
    _layers = Map.of(layers);
    _run('anatomo.setLayers(${jsonEncode(layers)})');
  }

  void setView(String view) => _run('anatomo.setView(${jsonEncode(view)})');

  void reset() => _run('anatomo.reset()');

  void setSpread(double value) =>
      _run('anatomo.setSpread(${value.toStringAsFixed(3)})');

  /// Part of the view (0..1, from the bottom) that is covered by the
  /// details sheet, so the selected part is shown above it.
  void setInset(double value) =>
      _run('anatomo.setInset(${value.toStringAsFixed(3)})');

  void selectKey(String key) => _run('anatomo.selectKey(${jsonEncode(key)})');

  void selectPart(String id) => _run('anatomo.selectPart(${jsonEncode(id)})');

  void clearSelection() => _run('anatomo.clear()');
}
