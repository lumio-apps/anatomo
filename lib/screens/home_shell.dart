import 'package:flutter/material.dart';

import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../settings.dart';
import '../theme.dart';
import 'explore_screen.dart';
import 'learn_screen.dart';
import 'part_screen.dart';
import 'parts_screen.dart';
import 'settings_screen.dart';

/// The four tabs of the app: Explore, Parts, Learn and Settings. It loads the
/// texts (in the app's language) and the current body once for all of them.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ExploreScreenState> _explore = GlobalKey<ExploreScreenState>();

  int _tab = 0;
  int _searchRequest = 0;
  bool _exploreSelected = false;

  BodyContent _content = BodyContent.empty;
  String? _contentLang;
  BodyManifest? _manifest;
  late String _sex;
  Map<String, List<String>> _links = const {};

  AppSettings get _settings => widget.settings;

  @override
  void initState() {
    super.initState();
    _sex = _settings.sex;
    _settings.addListener(_onSettings);
    _loadManifest();
    PartLinks.load().then((links) {
      if (mounted) setState(() => _links = links);
    });
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
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
      }).catchError((Object _) {});
    }
  }

  void _onSettings() {
    if (_settings.sex != _sex) {
      _sex = _settings.sex;
      setState(() => _manifest = null);
      _loadManifest();
    }
  }

  Future<void> _loadManifest() async {
    final sex = _sex;
    try {
      final m = await BodyManifest.load(sex);
      if (!mounted || sex != _sex) return;
      setState(() => _manifest = m);
    } catch (_) {
      // The body stays empty; the lists have no entries.
    }
  }

  void _onExploreSelection(bool selected) {
    if (_exploreSelected == selected) return;
    _exploreSelected = selected;
    // Called while Explore builds sometimes; update after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _search() {
    setState(() {
      _tab = 1;
      _searchRequest++;
    });
  }

  Future<void> _openPart(String key, String? partId, String? pieceName) async {
    final m = _manifest;
    if (m == null) return;
    final result = await Navigator.of(context).push<PartResult>(
      MaterialPageRoute(
        builder: (_) => PartScreen(
          settings: _settings,
          content: _content,
          manifest: m,
          links: _links,
          partKey: key,
          partId: partId,
          pieceName: pieceName,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _tab = 0);
    await _explore.currentState?.show(
      result.key,
      partId: result.partId,
      in3d: result.in3d,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final canLeave = _tab == 0 && !_exploreSelected;
    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_tab != 0) {
          setState(() => _tab = 0);
        } else {
          _explore.currentState?.clearSelection();
        }
      },
      child: Scaffold(
        backgroundColor: AnatomoColors.bg,
        body: IndexedStack(
          index: _tab,
          children: [
            ExploreScreen(
              key: _explore,
              settings: _settings,
              content: _content,
              manifest: _manifest,
              onOpenPart: _openPart,
              onSearch: _search,
              onSelectionChanged: _onExploreSelection,
            ),
            PartsScreen(
              settings: _settings,
              manifest: _manifest,
              content: _content,
              onOpenPart: _openPart,
              searchRequest: _searchRequest,
            ),
            LearnScreen(
              settings: _settings,
              content: _content,
              manifest: _manifest,
              onOpenPart: _openPart,
            ),
            SettingsScreen(settings: _settings),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AnatomoColors.line)),
          ),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.accessibility_new_outlined),
                selectedIcon: const Icon(Icons.accessibility_new_rounded),
                label: t.explore,
              ),
              NavigationDestination(
                icon: const Icon(Icons.format_list_bulleted_rounded),
                label: t.tabParts,
              ),
              NavigationDestination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school_rounded),
                label: t.learn,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: t.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
