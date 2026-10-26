import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as win;

import '../selection.dart';
import '../theme.dart';

export '../selection.dart';

/// Talks to the 3D viewer page (assets/web/viewer.js) inside the WebView:
/// the system WebView on Android, Microsoft Edge WebView2 on Windows.
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

  win.WebviewController? _win;
  StreamSubscription<dynamic>? _winMessages;

  /// The WebView2 controller on Windows, once it is ready to be shown.
  win.WebviewController? get windowsView => _winReady ? _win : null;
  bool _winReady = false;

  static bool get _onWindows => !kIsWeb && Platform.isWindows;

  bool _booted = false;
  bool _ready = false;
  double _progress = 0;
  String? _error;

  String _sex = 'male';
  bool _light = false;
  bool _busy = false;
  Uri? _page;
  Map<String, bool> _layers = const {};

  bool get ready => _ready;
  double get progress => _progress;

  /// A layer is being loaded in the background (the view stays usable).
  bool get busy => _busy;

  /// "webgl2", "load" or "context" when something went wrong.
  String? get error => _error;

  Uri _withQuality(String quality) =>
      _page!.replace(queryParameters: {'q': quality});

  Future<void> open(
    Uri page, {
    required String sex,
    required Map<String, bool> layers,
    required String quality,
  }) async {
    _page = page;
    _sex = sex;
    _layers = layers;
    _light = AnatomoColors.isLight;
    if (_onWindows) {
      await _openWindows(quality);
      return;
    }
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
    await web.loadRequest(_withQuality(quality));
  }

  Future<void> _openWindows(String quality) async {
    try {
      if (await win.WebviewController.getWebViewVersion() == null) {
        _fail('load');
        return;
      }
      final c = win.WebviewController();
      _win = c;
      await c.initialize();
      await c.setBackgroundColor(AnatomoColors.stage);
      await c.setPopupWindowPolicy(win.WebviewPopupWindowPolicy.deny);
      // The page talks to the app through window.AnatomoBridge, as on Android.
      await c.addScriptToExecuteOnDocumentCreated(
        'window.AnatomoBridge = { postMessage: function (s) { '
        'window.chrome.webview.postMessage(s); } };',
      );
      _winMessages = c.webMessage.listen((m) {
        _onMessage(m is String ? m : jsonEncode(m));
      });
      _winReady = true;
      notifyListeners();
      await c.loadUrl(_withQuality(quality).toString());
    } catch (_) {
      _fail('load');
    }
  }

  @override
  void dispose() {
    _winMessages?.cancel();
    _win?.dispose();
    super.dispose();
  }

  /// Graphics quality changed: the viewer page is opened again with it.
  Future<void> setQuality(String quality) async {
    if ((_web == null && _win == null) || _page == null) return;
    _error = null;
    _ready = false;
    _booted = false;
    _busy = false;
    _progress = 0;
    notifyListeners();
    final c = _win;
    if (c != null) {
      await c.loadUrl(_withQuality(quality).toString());
    } else {
      await _web!.loadRequest(_withQuality(quality));
    }
  }

  /// Loads the page again, for example after an error.
  Future<void> reload() async {
    _error = null;
    _ready = false;
    _booted = false;
    _progress = 0;
    notifyListeners();
    final c = _win;
    if (c != null) {
      await c.reload();
    } else {
      await _web?.reload();
    }
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
      case 'busy':
        _busy = msg['value'] == true;
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
    if (!_booted) return;
    try {
      final c = _win;
      if (c != null) {
        await c.executeScript(js);
        return;
      }
      await _web?.runJavaScript(js);
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
    _win?.setBackgroundColor(AnatomoColors.stage);
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
