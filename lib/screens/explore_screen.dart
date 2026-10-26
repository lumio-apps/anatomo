import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../layer_names.dart';
import '../settings.dart';
import '../theme.dart';
import '../viewer/asset_server.dart';
import '../viewer/viewer_controller.dart';
import '../widgets/logo.dart';
import '../widgets/part_sheet.dart';
import 'parts_screen.dart';
import 'settings_screen.dart';

/// Share of the 3D view covered by the details sheet.
const double kSheetShare = 0.56;

/// The main screen: the 3D body with its controls.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final AssetServer _server = AssetServer();
  late final ViewerController _viewer;

  BodyContent _content = BodyContent.empty;
  String? _contentLang;
  BodyManifest? _manifest;
  late String _sex;

  ViewerSelection? _selection;
  int _tab = 0;
  double _spread = 0;
  String _view = 'front';

  AppSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _sex = _settings.sex;
    _viewer = ViewerController(
      onSelect: _onSelect,
      onClear: _onViewerClear,
      onLayers: _settings.syncLayers,
    );
    _viewer.addListener(_onViewer);
    _settings.addListener(_onSettings);
    _start();
    _loadManifest();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    _viewer.removeListener(_onViewer);
    _viewer.dispose();
    _server.stop();
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

  Future<void> _start() async {
    try {
      final page = await _server.start();
      await _viewer.open(page, sex: _sex, layers: _settings.layers);
    } catch (_) {
      // The viewer shows its own error state.
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadManifest() async {
    final sex = _sex;
    try {
      final m = await BodyManifest.load(sex);
      if (mounted && sex == _sex) setState(() => _manifest = m);
    } catch (_) {
      // Search simply has no entries.
    }
  }

  void _onViewer() {
    if (mounted) setState(() {});
  }

  void _onSettings() {
    if (_settings.sex != _sex) {
      _sex = _settings.sex;
      _closeSheet(resetCamera: false);
      _manifest = null;
      _viewer.loadBody(_sex);
      _loadManifest();
      if (_sex == 'female' && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).femaleNote),
            duration: const Duration(seconds: 5),
          ));
      }
    }
    if (mounted) setState(() {});
  }

  void _onSelect(ViewerSelection selection) {
    setState(() => _selection = selection);
    _viewer.setInset(kSheetShare);
  }

  void _onViewerClear() {
    if (_selection == null) return;
    setState(() => _selection = null);
    _viewer.setInset(0);
  }

  void _closeSheet({bool resetCamera = true}) {
    if (_selection == null) return;
    setState(() => _selection = null);
    _viewer.setInset(0);
    if (resetCamera) _viewer.clearSelection();
  }

  void _toggleLayer(String layer) {
    final on = !(_settings.layers[layer] ?? false);
    _settings.setLayer(layer, on);
    _viewer.setLayers(_settings.layers);
  }

  Future<void> _openSearch() async {
    final manifest = _manifest ?? await BodyManifest.load(_sex);
    if (!mounted) return;
    final pick = await Navigator.of(context).push<PartsPick>(
      MaterialPageRoute(
        builder: (_) => PartsScreen(
          manifest: manifest,
          content: _content,
          sex: _sex,
        ),
      ),
    );
    if (pick == null) return;
    if (pick.partId != null) {
      _viewer.selectPart(pick.partId!);
    } else {
      _viewer.selectKey(pick.key);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(settings: _settings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final selection = _selection;
    _viewer.syncTheme();
    return PopScope(
      canPop: selection == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSheet();
      },
      child: Scaffold(
        backgroundColor: AnatomoColors.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(onSearch: _openSearch, onSettings: _openSettings, t: t),
              _ControlsRow(
                sex: _sex,
                layers: _settings.layers,
                onSex: _settings.setSex,
                onLayer: _toggleLayer,
                t: t,
              ),
              Expanded(child: _stage(t, selection)),
              if (selection == null) _dock(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stage(AppLocalizations t, ViewerSelection? selection) {
    final web = _viewer.web;
    final error = _viewer.error;
    return LayoutBuilder(
      builder: (context, constraints) {
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
            if (error != null)
              Positioned.fill(child: _ErrorView(code: error, onRetry: _viewer.reload, t: t))
            else if (!_viewer.ready)
              Positioned.fill(child: _LoadingView(progress: _viewer.progress, t: t)),
            if (_viewer.ready && error == null && selection == null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 10,
                child: IgnorePointer(
                  child: Text(
                    t.hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AnatomoColors.muted,
                      shadows: [Shadow(color: AnatomoColors.stage, blurRadius: 6)],
                    ),
                  ),
                ),
              ),
            if (selection != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: constraints.maxHeight * kSheetShare,
                child: PartSheet(
                  title: _content.nameOf(selection.key),
                  systemName: _content.systemName(
                    _content[selection.key]?.system ?? '',
                  ),
                  color: Color(
                    _manifest?.keyColors[selection.key] ?? 0xFF46BFB4,
                  ),
                  info: _content[selection.key],
                  partName: selection.whole ? null : selection.name,
                  tab: _tab,
                  onTab: (i) => setState(() => _tab = i),
                  onClose: _closeSheet,
                ),
              ),
          ],
        );
      },
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
                  onChanged: (v) {
                    setState(() => _view = v);
                    _viewer.setView(v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              _SquareButton(
                icon: Icons.restart_alt_rounded,
                tooltip: t.resetView,
                onTap: () {
                  setState(() {
                    _view = 'front';
                    _spread = 0;
                  });
                  _viewer.setSpread(0);
                  _viewer.reset();
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                t.spreadApart,
                style: TextStyle(fontSize: 13.5, color: AnatomoColors.muted),
              ),
              Expanded(
                child: Slider(
                  value: _spread,
                  onChanged: (v) {
                    setState(() => _spread = v);
                    _viewer.setSpread(v);
                  },
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
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onSearch,
    required this.onSettings,
    required this.t,
  });

  final VoidCallback onSearch;
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
