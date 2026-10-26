import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as win;

import '../atlas/atlas_controller.dart';
import '../atlas/atlas_view.dart';
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
import '../widgets/part_sheet.dart';
import 'parts_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

/// Share of the body view covered by the details sheet (phones).
const double kSheetShare = 0.56;

/// From this window width on, the screen uses the wide (desktop) layout.
const double kWideLayout = 900;

/// The main screen: the body (2D pictures, or 3D with the 3D pack) and its
/// controls.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Pack3D _pack = Pack3D.instance;
  late final AtlasController _atlas;
  AssetServer? _server;
  ViewerController? _viewer;

  BodyContent _content = BodyContent.empty;
  String? _contentLang;
  BodyManifest? _manifest;
  BodyManifest? _visible; // the parts the 2D pictures show
  late String _sex;
  late String _quality;

  ViewerSelection? _selection;
  int _tab = 0;
  double _spread = 0;
  String _view = 'front';
  bool _wide = false;

  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  AppSettings get _settings => widget.settings;

  /// The 3D view is shown (the user chose it and the pack is there).
  bool get _in3d => Pack3D.supported && _settings.mode == '3d' && _pack.ready;

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
    _settings.addListener(_onSettings);
    _pack.addListener(_onPack);
    _pack.init();
    _loadManifest();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    _pack.removeListener(_onPack);
    _stop3d();
    _atlas.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    if (lang != _contentLang) {
      _contentLang = lang;
      BodyContent.load(lang).then((c) {
        if (mounted && _contentLang == lang) setState(() => _content = c);
      }).catchError((_) {});
    }
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
  }

  void _onPack() {
    if (!mounted) return;
    if (!_pack.ready && _viewer != null) {
      _closeSheet(resetCamera: false);
      _stop3d();
    }
    setState(() {});
    _start3d();
  }

  /// Switches between the 2D pictures and the 3D view.
  Future<void> _setMode(String mode) async {
    if (mode == (_in3d ? '3d' : '2d')) return;
    if (mode == '3d' && !_pack.ready) {
      final ok = await _askForPack();
      if (!ok || !mounted) return;
    }
    _closeSheet(resetCamera: false);
    _settings.setMode(mode);
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

  /// Offers to download the 3D pack; true when it is ready afterwards.
  Future<bool> _askForPack() async {
    await showDialog<void>(
      context: context,
      builder: (_) => PackDialog(pack: _pack),
    );
    return _pack.ready;
  }

  // ---------------------------------------------------------------- data

  Future<void> _loadManifest() async {
    final sex = _sex;
    try {
      final m = await BodyManifest.load(sex);
      if (!mounted || sex != _sex) return;
      setState(() {
        _manifest = m;
        _visible = m.visibleOnly();
      });
      _atlas.setManifest(m);
    } catch (_) {
      // The 2D view stays empty; search has no entries.
    }
  }

  void _onViewer() {
    if (mounted) setState(() {});
  }

  void _onSettings() {
    if (!mounted) return;
    if (_settings.quality != _quality) {
      _quality = _settings.quality;
      if (_viewer != null) {
        _closeSheet(resetCamera: false);
        _viewer!.setQuality(_quality);
      }
    }
    if (_settings.sex != _sex) {
      _sex = _settings.sex;
      _closeSheet(resetCamera: false);
      _manifest = null;
      _visible = null;
      _viewer?.loadBody(_sex);
      _loadManifest();
    }
    _atlas.setLayers(_settings.layers);
    if (_settings.mode == '3d' && _pack.ready && _viewer == null) _start3d();
    setState(() {});
  }

  // ---------------------------------------------------------------- selection

  void _onSelect(ViewerSelection selection) {
    setState(() => _selection = selection);
    _applyInset();
  }

  void _onViewerClear() {
    if (_selection == null) return;
    setState(() => _selection = null);
    _applyInset();
  }

  void _applyInset() {
    final v = _selection != null && !_wide ? kSheetShare : 0.0;
    _atlas.setInset(v);
    _viewer?.setInset(v);
  }

  void _closeSheet({bool resetCamera = true}) {
    if (_selection == null) return;
    setState(() => _selection = null);
    _applyInset();
    if (resetCamera) {
      if (_in3d) {
        _viewer?.clearSelection();
      } else {
        _atlas.clear();
      }
    }
  }

  void _selectKey(String key) {
    if (_in3d) {
      _viewer?.selectKey(key);
    } else {
      _atlas.selectKey(key);
    }
  }

  void _selectPart(String id) {
    if (_in3d) {
      _viewer?.selectPart(id);
    } else {
      _atlas.selectPart(id);
    }
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
    _closeSheet(resetCamera: false);
    setState(() {
      _view = 'front';
      _spread = 0;
    });
    if (_in3d) {
      _viewer?.setSpread(0);
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

  // ---------------------------------------------------------------- pages

  BodyManifest? get _listManifest => _in3d ? _manifest : _visible;

  Future<void> _openSearch({String filter = 'all'}) async {
    final manifest = _listManifest ?? (await BodyManifest.load(_sex)).visibleOnly();
    if (!mounted) return;
    final pick = await Navigator.of(context).push<PartsPick>(
      MaterialPageRoute(
        builder: (_) => PartsScreen(
          manifest: manifest,
          content: _content,
          sex: _sex,
          favorites: _settings.favorites,
          initialFilter: filter,
        ),
      ),
    );
    if (pick == null) return;
    if (pick.partId != null) {
      _selectPart(pick.partId!);
    } else {
      _selectKey(pick.key);
    }
  }

  Future<void> _openQuiz() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(content: _content, settings: _settings),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(settings: _settings)),
    );
  }

  void _focusSearch() {
    if (_wide) {
      _searchFocus.requestFocus();
    } else {
      _openSearch();
    }
  }

  /// Puts the texts of a part on the clipboard.
  Future<void> _copyText(String key) async {
    final info = _content[key];
    final t = AppLocalizations.of(context);
    final buffer = StringBuffer(_content.nameOf(key));
    if (info != null) {
      buffer
        ..writeln(' (${_content.systemName(info.system)})')
        ..writeln(info.description)
        ..writeln()
        ..writeln('+ ${t.tabGood}')
        ..writeAll(info.good.map((s) => '  - $s\n'))
        ..writeln()
        ..writeln('+ ${t.tabBad}')
        ..writeAll(info.bad.map((s) => '  - $s\n'));
    }
    buffer
      ..writeln()
      ..write('Anatomo · github.com/lumio-apps/anatomo');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(t.copied),
        duration: const Duration(seconds: 2),
      ));
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    _viewer?.syncTheme();
    final wide = MediaQuery.sizeOf(context).width >= kWideLayout;
    if (wide != _wide) {
      _wide = wide;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyInset();
      });
    }
    final selection = _selection;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_selection != null) _closeSheet();
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): _focusSearch,
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: selection == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeSheet();
          },
          child: Scaffold(
            backgroundColor: AnatomoColors.bg,
            body: SafeArea(
              bottom: false,
              child: wide ? _desktop(t, selection) : _phone(t, selection),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phone(AppLocalizations t, ViewerSelection? selection) {
    return Column(
      children: [
        _TopBar(
          onSearch: _openSearch,
          onQuiz: _openQuiz,
          onSettings: _openSettings,
          t: t,
        ),
        _ControlsRow(
          sex: _sex,
          layers: _settings.layers,
          onSex: _settings.setSex,
          onLayer: _toggleLayer,
          t: t,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(child: _body(t, selection)),
                if (selection == null && _bodyShown)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 10,
                    child: _Hint(text: _in3d ? t.hint : t.hint2d),
                  ),
                if (selection != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: constraints.maxHeight * kSheetShare,
                    child: _sheet(selection, docked: false),
                  ),
              ],
            ),
          ),
        ),
        if (selection == null) _dock(t),
      ],
    );
  }

  /// The body is on screen (not loading, no error).
  bool get _bodyShown {
    if (!_in3d) return _manifest != null;
    final v = _viewer;
    return v != null && v.ready && v.error == null;
  }

  Widget _sheet(ViewerSelection selection, {required bool docked}) {
    final t = AppLocalizations.of(context);
    final fitted = _manifest?.fittedKeys.contains(selection.key) ?? false;
    return PartSheet(
      docked: docked,
      title: _content.nameOf(selection.key),
      systemName: _content.systemName(_content[selection.key]?.system ?? ''),
      color: Color(_manifest?.keyColors[selection.key] ?? 0xFF46BFB4),
      info: _content[selection.key],
      partName: selection.whole ? null : selection.name,
      note: fitted ? (_sex == 'female' ? t.fittedFromMale : t.fittedFromFemale) : null,
      tab: _tab,
      onTab: (i) => setState(() => _tab = i),
      onClose: _closeSheet,
      favorite: _settings.favorites.contains(selection.key),
      onFavorite: () => _settings.toggleFavorite(selection.key),
      onCopy: () => _copyText(selection.key),
    );
  }

  /// The 2D pictures or the 3D view.
  Widget _body(AppLocalizations t, ViewerSelection? selection) {
    if (!_in3d) return AtlasView(controller: _atlas, onHidden: _onHidden);
    final viewer = _viewer;
    final web = viewer?.web;
    final windowsView = viewer?.windowsView;
    final error = viewer?.error;
    final ready = viewer?.ready ?? false;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: AnatomoColors.stage)),
        if (windowsView != null)
          Positioned.fill(child: win.Webview(windowsView)),
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

  Widget _modeSwitch() {
    return _Segmented(
      options: const {'2d': '2D', '3d': '3D'},
      value: _in3d ? '3d' : '2d',
      onChanged: _setMode,
    );
  }

  Widget _dock(AppLocalizations t) {
    final views = {
      'front': t.viewFront,
      'back': t.viewBack,
      'side': t.viewSide,
    };
    return Container(
      decoration: BoxDecoration(
        color: AnatomoColors.bg,
        border: Border(top: BorderSide(color: AnatomoColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _Segmented(
                  expand: true,
                  options: views,
                  value: _view,
                  onChanged: _setView,
                ),
              ),
              if (Pack3D.supported) ...[
                const SizedBox(width: 8),
                _modeSwitch(),
              ],
              const SizedBox(width: 8),
              _SquareButton(
                icon: Icons.restart_alt_rounded,
                tooltip: t.resetView,
                onTap: _reset,
              ),
            ],
          ),
          if (_in3d) ...[
            const SizedBox(height: 6),
            _spreadRow(t),
          ],
        ],
      ),
    );
  }

  Widget _spreadRow(AppLocalizations t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.spreadApart,
          style: TextStyle(fontSize: 13.5, color: AnatomoColors.muted),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Slider(
              value: _spread,
              onChanged: (v) {
                setState(() => _spread = v);
                _viewer?.setSpread(v);
              },
            ),
          ),
        ),
        SizedBox(
          width: 78,
          child: Text(
            _spread < 0.005 ? t.assembled : '${(_spread * 100).round()}%',
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AnatomoColors.muted),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- wide

  Widget _desktop(AppLocalizations t, ViewerSelection? selection) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NavRail(
          t: t,
          onParts: () => _openSearch(),
          onQuiz: _openQuiz,
          onFavorites: () => _openSearch(filter: 'fav'),
          onSettings: _openSettings,
        ),
        SizedBox(width: 290, child: _sidebar(t, selection)),
        Expanded(child: _desktopStage(t, selection)),
        SizedBox(
          width: 360,
          child: selection != null
              ? _sheet(selection, docked: true)
              : _EmptyPanel(t: t),
        ),
      ],
    );
  }

  Widget _sidebar(AppLocalizations t, ViewerSelection? selection) {
    final names = layerNames(t);
    final manifest = _listManifest;
    final q = _search.text.trim().toLowerCase();
    final keys = manifest == null
        ? <String>[]
        : (manifest.keyLayers.keys.where((k) {
            if (q.isEmpty) return true;
            final info = _content[k];
            return _content.nameOf(k).toLowerCase().contains(q) ||
                (info != null &&
                    _content.systemName(info.system).toLowerCase().contains(q));
          }).toList()
          ..sort((a, b) => _content.nameOf(a).compareTo(_content.nameOf(b))));
    return Container(
      decoration: BoxDecoration(
        color: AnatomoColors.panel,
        border: BorderDirectional(end: BorderSide(color: AnatomoColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            focusNode: _searchFocus,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: t.searchParts,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: AnatomoColors.panel2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AnatomoColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AnatomoColors.line),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SideTitle(t.layers),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final layer in kLayers)
                SizedBox(
                  width: 128,
                  height: 36,
                  child: _LayerChip(
                    label: names[layer] ?? layer,
                    on: _settings.layers[layer] ?? false,
                    onTap: () => _toggleLayer(layer),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SideTitle(t.allParts),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: keys.length,
              padding: const EdgeInsets.only(bottom: 12),
              itemBuilder: (context, i) {
                final k = keys[i];
                final on = selection?.key == k;
                return Material(
                  color: on ? AnatomoColors.tint : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _selectKey(k),
                    child: SizedBox(
                      height: 42,
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(manifest!.keyColors[k] ?? 0xFF46BFB4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _content.nameOf(k),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_settings.favorites.contains(k))
                            Icon(Icons.star_rounded, size: 16, color: AnatomoColors.coral),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopStage(AppLocalizations t, ViewerSelection? selection) {
    final views = {
      'front': t.viewFront,
      'back': t.viewBack,
      'side': t.viewSide,
    };
    return Stack(
      children: [
        Positioned.fill(child: _body(t, selection)),
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _Segmented(
                options: {'male': t.male, 'female': t.female},
                value: _sex,
                onChanged: _settings.setSex,
              ),
              _Segmented(options: views, value: _view, onChanged: _setView),
              if (Pack3D.supported) _modeSwitch(),
              _SquareButton(
                icon: Icons.restart_alt_rounded,
                tooltip: t.resetView,
                onTap: _reset,
              ),
            ],
          ),
        ),
        if (_bodyShown)
          Positioned(
            left: 16,
            bottom: 14,
            right: 80,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _Hint(text: _in3d ? t.hint3dDesktop : t.hintDesktop),
            ),
          ),
        if (_in3d && _bodyShown)
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(child: _spreadRow(t)),
          ),
        if (!_in3d)
          Positioned(
            right: 14,
            bottom: 14,
            child: Column(
              children: [
                _SquareButton(
                  icon: Icons.add_rounded,
                  tooltip: t.zoomIn,
                  onTap: () => _atlas.zoomBy(1.4),
                ),
                const SizedBox(height: 8),
                _SquareButton(
                  icon: Icons.remove_rounded,
                  tooltip: t.zoomOut,
                  onTap: () => _atlas.zoomBy(1 / 1.4),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          color: AnatomoColors.muted,
          shadows: [Shadow(color: AnatomoColors.stage, blurRadius: 6)],
        ),
      ),
    );
  }
}

class _SideTitle extends StatelessWidget {
  const _SideTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AnatomoColors.muted,
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.t,
    required this.onParts,
    required this.onQuiz,
    required this.onFavorites,
    required this.onSettings,
  });

  final AppLocalizations t;
  final VoidCallback onParts;
  final VoidCallback onQuiz;
  final VoidCallback onFavorites;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: AnatomoColors.bg,
        border: BorderDirectional(end: BorderSide(color: AnatomoColors.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const AnatomoMark(size: 40),
          const SizedBox(height: 16),
          _RailButton(icon: Icons.view_in_ar_rounded, label: t.explore, selected: true, onTap: () {}),
          _RailButton(icon: Icons.format_list_bulleted_rounded, label: t.allParts, onTap: onParts),
          _RailButton(icon: Icons.quiz_outlined, label: t.quiz, onTap: onQuiz),
          _RailButton(icon: Icons.star_outline_rounded, label: t.favorites, onTap: onFavorites),
          const Spacer(),
          _RailButton(icon: Icons.settings_outlined, label: t.settings, onTap: onSettings),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AnatomoColors.accent : AnatomoColors.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? AnatomoColors.tint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.t});

  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AnatomoColors.panel,
        border: BorderDirectional(start: BorderSide(color: AnatomoColors.line)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AnatomoColors.tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.touch_app_outlined, color: AnatomoColors.accent, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            t.selectPartTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            t.selectPartText,
            style: TextStyle(fontSize: 14, height: 1.5, color: AnatomoColors.body),
          ),
          const SizedBox(height: 24),
          _SideTitle(t.keyboard),
          const SizedBox(height: 10),
          _KeyRow(label: t.searchParts, keys: const ['Ctrl', 'F']),
          const SizedBox(height: 8),
          _KeyRow(label: t.close, keys: const ['Esc']),
          const Spacer(),
          Text(
            t.notMedical,
            style: TextStyle(fontSize: 12, color: AnatomoColors.muted),
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.label, required this.keys});

  final String label;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        for (final k in keys)
          Container(
            margin: const EdgeInsetsDirectional.only(start: 4),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AnatomoColors.panel2,
              border: Border.all(color: AnatomoColors.line),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(k, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

/// Asks to download the 3D pack and shows the download.
class PackDialog extends StatefulWidget {
  const PackDialog({super.key, required this.pack});

  final Pack3D pack;

  @override
  State<PackDialog> createState() => _PackDialogState();
}

class _PackDialogState extends State<PackDialog> {
  bool _closed = false;

  Pack3D get _pack => widget.pack;

  @override
  void initState() {
    super.initState();
    _pack.addListener(_changed);
  }

  @override
  void dispose() {
    _pack.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    if (_pack.ready) {
      _close();
    } else {
      setState(() {});
    }
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = _pack.state;
    final downloading = state == PackState.downloading;
    return AlertDialog(
      backgroundColor: AnatomoColors.panel,
      title: Text(t.pack3dTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.pack3dNote(kPackSizeMb)),
          if (downloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _pack.progress > 0 ? _pack.progress : null),
            const SizedBox(height: 8),
            Text(t.downloading((_pack.progress * 100).round())),
          ],
          if (state == PackState.failed) ...[
            const SizedBox(height: 12),
            Text(t.pack3dFailed, style: TextStyle(color: AnatomoColors.bad)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (downloading) _pack.cancel();
            _close();
          },
          child: Text(downloading ? t.cancel : t.later),
        ),
        if (!downloading)
          FilledButton(
            onPressed: _pack.download,
            child: Text(t.pack3dDownload),
          ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onSearch,
    required this.onQuiz,
    required this.onSettings,
    required this.t,
  });

  final VoidCallback onSearch;
  final VoidCallback onQuiz;
  final VoidCallback onSettings;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          const AnatomoMark(size: 36),
          const SizedBox(width: 10),
          const AnatomoWordmark(size: 20),
          const Spacer(),
          _SquareButton(icon: Icons.search_rounded, tooltip: t.searchParts, onTap: onSearch),
          const SizedBox(width: 8),
          _SquareButton(icon: Icons.quiz_outlined, tooltip: t.quiz, onTap: onQuiz),
          const SizedBox(width: 8),
          _SquareButton(icon: Icons.settings_outlined, tooltip: t.settings, onTap: onSettings),
        ],
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.sex,
    required this.layers,
    required this.onSex,
    required this.onLayer,
    required this.t,
  });

  final String sex;
  final Map<String, bool> layers;
  final ValueChanged<String> onSex;
  final ValueChanged<String> onLayer;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final names = layerNames(t);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AnatomoColors.line)),
      ),
      child: Row(
        children: [
          _Segmented(
            options: {'male': t.male, 'female': t.female},
            value: sex,
            onChanged: onSex,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.only(end: 16),
                children: [
                  for (final layer in kLayers)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: _LayerChip(
                        label: names[layer] ?? layer,
                        on: layers[layer] ?? false,
                        onTap: () => onLayer(layer),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      button: true,
      child: Material(
        color: on ? AnatomoColors.text : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: on ? AnatomoColors.text : AnatomoColors.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: on ? AnatomoColors.bg : AnatomoColors.body,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.value,
    required this.onChanged,
    this.expand = false,
  });

  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onChanged;

  /// Share the available width equally between the options.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (final entry in options.entries)
        Material(
          color: entry.key == value ? AnatomoColors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () => onChanged(entry.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                widthFactor: 1,
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: entry.key == value
                        ? AnatomoColors.bg
                        : AnatomoColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AnatomoColors.panel,
        border: Border.all(color: AnatomoColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in buttons) expand ? Expanded(child: b) : b,
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AnatomoColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AnatomoColors.line),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 21, color: AnatomoColors.text),
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
