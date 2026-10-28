import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../atlas/atlas_controller.dart';
import '../atlas/atlas_view.dart';
import '../atlas/part_picture.dart';
import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../layer_names.dart';
import '../pack/pack3d.dart';
import '../settings.dart';
import '../theme.dart';
import '../viewer/asset_server.dart';
import '../viewer/viewer_controller.dart';
import '../widgets/logo.dart';
import '../widgets/pack_dialog.dart';
import '../widgets/ui.dart';

/// The Explore tab: the body (2D pictures, or 3D with the 3D pack), its
/// layers and tools. Tapping a part shows a small card; "Details" opens the
/// part's page.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.settings,
    required this.content,
    required this.manifest,
    required this.onOpenPart,
    required this.onSearch,
    required this.onSelectionChanged,
  });

  final AppSettings settings;
  final BodyContent content;

  /// The current body, or null while it loads.
  final BodyManifest? manifest;

  /// Opens the page of a part (key, single piece id, piece name).
  final void Function(String key, String? partId, String? pieceName) onOpenPart;
  final VoidCallback onSearch;
  final ValueChanged<bool> onSelectionChanged;

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final Pack3D _pack = Pack3D.instance;
  late final AtlasController _atlas;
  AssetServer? _server;
  ViewerController? _viewer;

  late String _sex;
  late String _quality;

  ViewerSelection? _selection;
  String _view = 'front';
  double _spread = 0;
  double _cut = 0;
  bool _autoRotate = false;
  bool _labels = false;
  double _appliedInset = -1;

  // A part to select as soon as the 3D view (or the body) is ready.
  String? _pendingKey;
  String? _pendingPart;

  AppSettings get _settings => widget.settings;

  /// The 3D view is shown (the user chose it and the pack is there).
  bool get _in3d => Pack3D.supported && _settings.mode == '3d' && _pack.ready;

  bool get hasSelection => _selection != null;

  @override
  void initState() {
    super.initState();
    _sex = _settings.sex;
    _quality = _settings.quality;
    _atlas = AtlasController(
      onSelect: _onSelect,
      onClear: _onViewerClear,
      onLayers: _settings.syncLayers,
      layers: _settings.layers,
    );
    final m = widget.manifest;
    if (m != null) _atlas.setManifest(m);
    _settings.addListener(_onSettings);
    _pack.addListener(_onPack);
    _pack.init();
  }

  @override
  void didUpdateWidget(ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final m = widget.manifest;
    if (m != null && m != oldWidget.manifest) {
      _atlas.setManifest(m);
      if (_selection != null) {
        _selection = null;
        widget.onSelectionChanged(false);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyPending();
      });
    }
    if (_labels && widget.content != oldWidget.content) {
      _viewer?.setLabels(_labelNames());
    }
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    _pack.removeListener(_onPack);
    _stop3d();
    _atlas.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- 3D

  Future<void> _start3d() async {
    if (!_in3d || _viewer != null) return;
    final models = _pack.modelsPath;
    if (models == null) return;
    final server = AssetServer(modelsPath: models);
    final viewer = ViewerController(
      onSelect: _onSelect,
      onClear: _onViewerClear,
      onLayers: _settings.syncLayers,
    );
    viewer.addListener(_onViewer);
    viewer.setAutoRotate(_autoRotate);
    viewer.setCut(_cut);
    viewer.setSpread(_spread);
    viewer.setLabels(_labels ? _labelNames() : null);
    _server = server;
    _viewer = viewer;
    try {
      final page = await server.start();
      await viewer.open(
        page,
        sex: _sex,
        layers: _settings.layers,
        quality: _quality,
      );
    } catch (_) {
      // The viewer shows its own error state.
    }
    if (mounted) setState(() {});
  }

  void _stop3d() {
    final viewer = _viewer;
    _viewer = null;
    viewer?.removeListener(_onViewer);
    viewer?.dispose();
    _server?.stop();
    _server = null;
    _appliedInset = -1;
  }

  void _onPack() {
    if (!mounted) return;
    if (!_pack.ready && _viewer != null) {
      clearSelection(resetCamera: false);
      _stop3d();
    }
    setState(() {});
    _start3d();
  }

  /// Switches between the 2D pictures and the 3D view.
  Future<void> _setMode(String mode) async {
    if (mode == (_in3d ? '3d' : '2d')) return;
    if (mode == '3d' && !_pack.ready) {
      final ok = await askForPack(context);
      if (!ok || !mounted) return;
    }
    clearSelection(resetCamera: false);
    _settings.setMode(mode);
    _appliedInset = -1;
    if (mode == '3d') {
      final viewer = _viewer;
      if (viewer == null) {
        await _start3d();
      } else {
        viewer.setLayers(_settings.layers);
        viewer.loadBody(_sex);
        viewer.clearSelection();
      }
    } else {
      _atlas.clear();
    }
  }

  Map<String, String> _labelNames() {
    final m = widget.manifest;
    if (m == null) return const {};
    return {
      for (final k in m.keyLayers.keys)
        if (m.keyWhole[k] ?? false) k: widget.content.nameOf(k),
    };
  }

  // ---------------------------------------------------------------- data

  void _onViewer() {
    if (!mounted) return;
    _applyPending();
    setState(() {});
  }

  void _onSettings() {
    if (!mounted) return;
    if (_settings.quality != _quality) {
      _quality = _settings.quality;
      if (_viewer != null) {
        clearSelection(resetCamera: false);
        _viewer!.setQuality(_quality);
      }
    }
    if (_settings.sex != _sex) {
      _sex = _settings.sex;
      clearSelection(resetCamera: false);
      _viewer?.loadBody(_sex);
    }
    _atlas.setLayers(_settings.layers);
    if (_settings.mode == '3d' && _pack.ready && _viewer == null) _start3d();
    setState(() {});
  }

  // ---------------------------------------------------------------- selection

  void _onSelect(ViewerSelection selection) {
    final had = _selection != null;
    setState(() => _selection = selection);
    if (!had) widget.onSelectionChanged(true);
  }

  void _onViewerClear() {
    if (_selection == null) return;
    setState(() => _selection = null);
    widget.onSelectionChanged(false);
  }

  /// Closes the small card (and fades nothing any more).
  void clearSelection({bool resetCamera = true}) {
    if (_selection == null) return;
    setState(() => _selection = null);
    widget.onSelectionChanged(false);
    if (resetCamera) {
      if (_in3d) {
        _viewer?.clearSelection();
      } else {
        _atlas.clear();
      }
    }
  }

  /// Shows a part on the body (from the parts list or a part's page).
  Future<void> show(String key, {String? partId, bool in3d = false}) async {
    if (in3d && !_in3d) {
      await _setMode('3d');
      if (!mounted || !_in3d) return;
    }
    _pendingKey = key;
    _pendingPart = partId;
    _applyPending();
  }

  void _applyPending() {
    final key = _pendingKey;
    if (key == null) return;
    final part = _pendingPart;
    if (_in3d) {
      final v = _viewer;
      if (v == null || !v.ready) return;
      _pendingKey = null;
      _pendingPart = null;
      if (part != null) {
        v.selectPart(part);
      } else {
        v.selectKey(key);
      }
      return;
    }
    if (_atlas.manifest == null) return;
    _pendingKey = null;
    _pendingPart = null;
    if (part == null || !_atlas.selectPart(part)) _atlas.selectKey(key);
  }

  void _toggleLayer(String layer) {
    final on = !(_settings.layers[layer] ?? false);
    _settings.setLayer(layer, on);
    if (_in3d) _viewer?.setLayers(_settings.layers);
  }

  void _setView(String view) {
    setState(() => _view = view);
    if (_in3d) {
      _viewer?.setView(view);
    } else {
      _atlas.setView(view);
    }
  }

  void _reset() {
    clearSelection(resetCamera: false);
    setState(() {
      _view = 'front';
      _spread = 0;
      _cut = 0;
    });
    if (_in3d) {
      _viewer?.setSpread(0);
      _viewer?.setCut(0);
      _viewer?.reset();
    } else {
      _atlas.reset();
    }
  }

  void _onHidden() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).hiddenHere),
        duration: const Duration(seconds: 4),
      ));
  }

  void _setInset(double inset) {
    if ((inset - _appliedInset).abs() < 0.004) return;
    _appliedInset = inset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _atlas.setInset(inset);
      _viewer?.setInset(inset);
    });
  }

  // ---------------------------------------------------------------- build

  /// The body is on screen (not loading, no error).
  bool get _bodyShown {
    if (!_in3d) return widget.manifest != null;
    final v = _viewer;
    return v != null && v.ready && v.error == null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    _viewer?.syncTheme();
    final names = layerNames(t);
    return ColoredBox(
      color: AnatomoColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  const AnatomoMark(size: 36),
                  const SizedBox(width: 10),
                  const AnatomoWordmark(size: 21),
                  const Spacer(),
                  Segmented(
                    options: {'male': t.male, 'female': t.female},
                    value: _sex,
                    onChanged: _settings.setSex,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: _SearchBox(hint: t.searchHint, onTap: widget.onSearch),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final layer in kLayers)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ToggleChip(
                        label: names[layer] ?? layer,
                        on: _settings.layers[layer] ?? false,
                        dot: Color(kLayerColors[layer] ?? 0xFF888888),
                        onTap: () => _toggleLayer(layer),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => _stage(t, constraints.maxHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stage(AppLocalizations t, double height) {
    final selection = _selection;
    final in3d = _in3d;
    final show3dPanel = selection == null && in3d && _bodyShown;
    final covered = selection != null ? 104.0 : (show3dPanel ? 214.0 : 28.0);
    _setInset(height <= 0 ? 0.0 : (covered / height).clamp(0.0, 0.6).toDouble());
    return Stack(
      children: [
        Positioned.fill(child: _body(t)),
        PositionedDirectional(
          start: 12,
          top: 8,
          child: Segmented(
            vertical: true,
            itemWidth: 64,
            options: {
              'front': t.viewFront,
              'back': t.viewBack,
              'side': t.viewSide,
            },
            value: _view,
            onChanged: _setView,
          ),
        ),
        PositionedDirectional(
          end: 12,
          top: 8,
          child: Column(
            children: [
              if (Pack3D.supported)
                Segmented(
                  vertical: true,
                  itemWidth: 50,
                  options: const {'2d': '2D', '3d': '3D'},
                  value: in3d ? '3d' : '2d',
                  onChanged: _setMode,
                ),
              if (!in3d) ...[
                const SizedBox(height: 8),
                SquareButton(
                  icon: Icons.add_rounded,
                  tooltip: t.zoomIn,
                  size: 50,
                  onTap: () => _atlas.zoomBy(1.4),
                ),
                const SizedBox(height: 8),
                SquareButton(
                  icon: Icons.remove_rounded,
                  tooltip: t.zoomOut,
                  size: 50,
                  onTap: () => _atlas.zoomBy(1 / 1.4),
                ),
              ],
              const SizedBox(height: 8),
              SquareButton(
                icon: Icons.restart_alt_rounded,
                tooltip: t.resetView,
                size: 50,
                onTap: _reset,
              ),
            ],
          ),
        ),
        if (selection != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _PeekCard(
              selection: selection,
              content: widget.content,
              manifest: widget.manifest,
              favorite: _settings.favorites.contains(selection.key),
              onFavorite: () => _settings.toggleFavorite(selection.key),
              onOpen: () => widget.onOpenPart(
                selection.key,
                selection.whole ? null : selection.partId,
                selection.whole ? null : selection.name,
              ),
              onClose: clearSelection,
            ),
          )
        else if (show3dPanel)
          Positioned(left: 12, right: 12, bottom: 12, child: _threeDPanel(t))
        else if (_bodyShown)
          Positioned(
            left: 16,
            right: 16,
            bottom: 8,
            child: IgnorePointer(
              child: Text(
                in3d ? t.hint : t.hint2d,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
              ),
            ),
          ),
      ],
    );
  }

  Widget _threeDPanel(AppLocalizations t) {
    return Panel(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SliderRow(
            label: t.spreadApart,
            value: _spread,
            valueText: _spread < 0.005 ? t.assembled : '${(_spread * 100).round()}%',
            onChanged: (v) {
              setState(() => _spread = v);
              _viewer?.setSpread(v);
            },
          ),
          _SliderRow(
            label: t.crossSection,
            value: _cut,
            valueText: _cut < 0.005 ? t.off : '${(_cut * 100).round()}%',
            onChanged: (v) {
              setState(() => _cut = v);
              _viewer?.setCut(v);
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _ToolTile(
                  icon: Icons.autorenew_rounded,
                  label: t.autoRotate,
                  on: _autoRotate,
                  onTap: () {
                    setState(() => _autoRotate = !_autoRotate);
                    _viewer?.setAutoRotate(_autoRotate);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ToolTile(
                  icon: Icons.label_outline_rounded,
                  label: t.labels,
                  on: _labels,
                  onTap: () {
                    setState(() => _labels = !_labels);
                    _viewer?.setLabels(_labels ? _labelNames() : null);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The 2D pictures or the 3D view.
  Widget _body(AppLocalizations t) {
    if (!_in3d) return AtlasView(controller: _atlas, onHidden: _onHidden);
    final viewer = _viewer;
    final web = viewer?.web;
    final error = viewer?.error;
    final ready = viewer?.ready ?? false;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AnatomoColors.stage)),
        if (web != null)
          Positioned.fill(
            child: WebViewWidget(
              controller: web,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
          ),
        if ((viewer?.busy ?? false) && ready && error == null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(
              minHeight: 3,
              color: AnatomoColors.accent,
              backgroundColor: Colors.transparent,
            ),
          ),
        if (error != null)
          Positioned.fill(
            child: _ErrorView(code: error, onRetry: viewer!.reload, t: t),
          )
        else if (!ready)
          Positioned.fill(
            child: _LoadingView(progress: viewer?.progress ?? 0.0, t: t),
          ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      child: Panel(
        radius: 16,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded, color: AnatomoColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: AnatomoColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The small card over the body when a part is tapped.
class _PeekCard extends StatelessWidget {
  const _PeekCard({
    required this.selection,
    required this.content,
    required this.manifest,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
    required this.onClose,
  });

  final ViewerSelection selection;
  final BodyContent content;
  final BodyManifest? manifest;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final key = selection.key;
    final info = content[key];
    final system = info == null ? '' : content.systemName(info.system);
    final subtitle = selection.whole ? system : selection.name;
    final m = manifest;
    return Material(
      color: AnatomoColors.panel,
      elevation: 6,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 4, 10),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AnatomoColors.picture,
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: m == null
                    ? null
                    : PartPicture(
                        manifest: m,
                        partKey: key,
                        partId: selection.whole ? null : selection.partId,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content.nameOf(key),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (info != null) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: systemColor(info.system),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: AnatomoColors.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.details}  ›',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AnatomoColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite ? t.removeFavorite : t.addFavorite,
                onPressed: onFavorite,
                icon: Icon(
                  favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: favorite ? AnatomoColors.coral : AnatomoColors.muted,
                ),
              ),
              IconButton(
                tooltip: t.showWholeBody,
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, color: AnatomoColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.valueText,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String valueText;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Slider(value: value, onChanged: onChanged),
        ),
        SizedBox(
          width: 72,
          child: Text(
            valueText,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
          ),
        ),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.on,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      button: true,
      child: Material(
        color: on ? AnatomoColors.tint : AnatomoColors.panel2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: on ? AnatomoColors.accent : AnatomoColors.line),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: on ? AnatomoColors.accent : AnatomoColors.text),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: on ? AnatomoColors.accent : AnatomoColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.progress, required this.t});

  final double progress;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AnatomoColors.stage,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnatomoMark(size: 64),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress <= 0 ? null : progress,
                    minHeight: 6,
                    color: AnatomoColors.accent,
                    backgroundColor: AnatomoColors.line,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.loading((progress * 100).round()),
                textAlign: TextAlign.center,
                style: TextStyle(color: AnatomoColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.code, required this.onRetry, required this.t});

  final String code;
  final Future<void> Function() onRetry;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AnatomoColors.stage,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar_rounded, size: 48, color: AnatomoColors.muted),
              const SizedBox(height: 16),
              Text(
                code == 'webgl2' ? t.errorWebgl : t.errorLoad,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AnatomoColors.accent,
                  foregroundColor: AnatomoColors.accentInk,
                ),
                child: Text(t.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
