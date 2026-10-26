import 'package:flutter/foundation.dart';

import '../body_manifest.dart';
import '../selection.dart';
import '../settings.dart';

/// Letters of the layers in the names of the 2D pictures, in file order.
const Map<String, String> kAtlasLetters = {
  'organs': 'o',
  'bones': 'b',
  'muscles': 'm',
  'vessels': 'v',
  'nerves': 'n',
};

/// The state of the 2D body: which body, side and layers are shown and what is
/// selected. [AtlasView] draws it; the explore screen talks to it the same way
/// it talks to the 3D view.
class AtlasController extends ChangeNotifier {
  AtlasController({
    required this.onSelect,
    required this.onClear,
    required this.onLayers,
    required Map<String, bool> layers,
  }) : _layers = Map.of(layers);

  final void Function(ViewerSelection selection) onSelect;
  final VoidCallback onClear;
  final void Function(Map<String, bool> layers) onLayers;

  BodyManifest? _manifest;
  String _view = 'front';
  final Map<String, bool> _layers;
  Set<int> _selected = const {};
  double _inset = 0;

  /// Bumped when the view should zoom to the selection / back to the body.
  int focusRequest = 0;
  int resetRequest = 0;

  /// Zoom steps asked for by the + and - buttons (applied by the view).
  double pendingZoom = 1;

  BodyManifest? get manifest => _manifest;
  String get sex => _manifest?.sex ?? 'male';
  String get view => _view;
  Map<String, bool> get layers => Map.unmodifiable(_layers);
  Set<int> get selected => _selected;

  /// Part of the stage (0..1, from the bottom) covered by the details sheet.
  double get inset => _inset;

  /// Name of the picture of the inner layers, for example "obm", or '' when
  /// only the skin (or nothing) is on.
  String get mix {
    final b = StringBuffer();
    kAtlasLetters.forEach((layer, letter) {
      if (_layers[layer] ?? false) b.write(letter);
    });
    return b.toString();
  }

  bool get skinOn => _layers['skin'] ?? false;

  void setManifest(BodyManifest manifest) {
    _manifest = manifest;
    _selected = const {};
    resetRequest++;
    notifyListeners();
  }

  void setView(String view) {
    if (_view == view) return;
    _view = view;
    if (_selected.isNotEmpty) focusRequest++;
    notifyListeners();
  }

  void setInset(double value) {
    _inset = value.clamp(0, 0.7).toDouble();
    if (_selected.isNotEmpty) focusRequest++;
    notifyListeners();
  }

  void setLayers(Map<String, bool> layers) {
    for (final l in kLayers) {
      final v = layers[l];
      if (v != null) _layers[l] = v;
    }
    final m = _manifest;
    if (m != null && _selected.isNotEmpty) {
      final layer = m.keyLayers[m.parts[_selected.first].key];
      if (layer != null && !(_layers[layer] ?? false)) {
        _selected = const {};
        onClear();
      }
    }
    notifyListeners();
  }

  void zoomBy(double factor) {
    pendingZoom *= factor;
    notifyListeners();
  }

  void reset() {
    _view = 'front';
    _selected = const {};
    resetRequest++;
    notifyListeners();
  }

  /// Clears the selection without telling the screen (it asked for it).
  void clear() {
    if (_selected.isEmpty) return;
    _selected = const {};
    resetRequest++;
    notifyListeners();
  }

  bool selectKey(String key) {
    final m = _manifest;
    if (m == null) return false;
    final list = m.partsOf(key);
    if (list.isEmpty) return false;
    final whole = m.keyWhole[key] ?? true;
    _select(whole ? list : [list.first]);
    return true;
  }

  bool selectPart(String id) {
    final m = _manifest;
    if (m == null) return false;
    for (final p in m.parts) {
      if (p.id == id) {
        selectIndex(p.index);
        return true;
      }
    }
    return false;
  }

  /// A part was tapped (its index in the model).
  void tapIndex(int index) {
    final m = _manifest;
    if (m == null || index < 0 || index >= m.parts.length) return;
    final p = m.parts[index];
    final whole = m.keyWhole[p.key] ?? true;
    if (_selected.contains(index) && (whole || _selected.length == 1)) return;
    selectIndex(index);
  }

  /// The empty stage was tapped.
  void tapEmpty() {
    if (_selected.isEmpty) return;
    _selected = const {};
    resetRequest++;
    notifyListeners();
    onClear();
  }

  void selectIndex(int index) {
    final m = _manifest;
    if (m == null) return;
    final p = m.parts[index];
    final whole = m.keyWhole[p.key] ?? true;
    _select(whole ? m.partsOf(p.key) : [p]);
  }

  void _select(List<BodyPart> list) {
    final m = _manifest!;
    final first = list.first;
    final layer = m.keyLayers[first.key] ?? 'organs';
    if (!(_layers[layer] ?? false)) {
      _layers[layer] = true;
      onLayers(Map.of(_layers));
    }
    _selected = {for (final p in list) p.index};
    focusRequest++;
    notifyListeners();
    final whole = m.keyWhole[first.key] ?? true;
    onSelect(ViewerSelection(
      key: first.key,
      name: first.name,
      layer: layer,
      whole: whole,
      partId: whole ? null : first.id,
    ));
  }
}
