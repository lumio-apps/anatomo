import 'package:flutter/material.dart';

import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../layer_names.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// The Parts tab: search and browse every part of the body, by layer or by
/// body system.
class PartsScreen extends StatefulWidget {
  const PartsScreen({
    super.key,
    required this.settings,
    required this.manifest,
    required this.content,
    required this.onOpenPart,
    this.searchRequest = 0,
  });

  final AppSettings settings;
  final BodyManifest? manifest;
  final BodyContent content;

  /// Opens the page of a part (key, single piece id, piece name).
  final void Function(String key, String? partId, String? pieceName) onOpenPart;

  /// Bumped when the search field should get the keyboard.
  final int searchRequest;

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focus = FocusNode();

  /// 'all', 'fav' or a layer.
  String _filter = 'all';

  /// A body system, or null for all.
  String? _system;

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_changed);
  }

  @override
  void didUpdateWidget(PartsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchRequest != oldWidget.searchRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    widget.settings.removeListener(_changed);
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final manifest = widget.manifest;
    if (manifest == null) {
      return Center(child: CircularProgressIndicator(color: AnatomoColors.accent));
    }
    final names = layerNames(t);
    final content = widget.content;
    final favorites = widget.settings.favorites;
    final q = _query.text.trim().toLowerCase();

    final keys = manifest.keyLayers.keys.where((k) {
      if (_filter == 'fav') {
        if (!favorites.contains(k)) return false;
      } else if (_filter != 'all' && manifest.keyLayers[k] != _filter) {
        return false;
      }
      final info = content[k];
      if (_system != null && info?.system != _system) return false;
      if (q.isEmpty) return true;
      return content.nameOf(k).toLowerCase().contains(q) ||
          k.replaceAll('_', ' ').contains(q) ||
          (info != null &&
              content.systemName(info.system).toLowerCase().contains(q));
    }).toList()
      ..sort((a, b) => content.nameOf(a).compareTo(content.nameOf(b)));

    final detailed = q.length < 2
        ? const <BodyPart>[]
        : manifest.parts
            .where((p) =>
                p.name.toLowerCase().contains(q) &&
                (_filter == 'all' || manifest.keyLayers[p.key] == _filter))
            .take(80)
            .toList();

    final layersPresent =
        kLayers.where((l) => manifest.keyLayers.values.contains(l)).toList();

    // Systems with the number of parts in each.
    final systemCounts = <String, int>{};
    for (final k in manifest.keyLayers.keys) {
      final s = content[k]?.system;
      if (s != null && s.isNotEmpty) systemCounts[s] = (systemCounts[s] ?? 0) + 1;
    }
    final systems = systemCounts.keys.toList()
      ..sort((a, b) => content.systemName(a).compareTo(content.systemName(b)));
    final browsing = q.isEmpty && _filter == 'all' && _system == null;

    final children = <Widget>[];
    if (manifest.sex == 'female') {
      children.add(_Note(text: t.femaleNote));
    }
    if (browsing && systems.isNotEmpty) {
      children.add(SectionTitle(t.browseBySystem));
      children.add(GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.05,
        children: [
          for (final s in systems)
            Panel(
              radius: 16,
              onTap: () => setState(() => _system = s),
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 6,
                    decoration: BoxDecoration(
                      color: systemColor(s),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    content.systemName(s),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.2),
                  ),
                  Text(
                    t.partsCount(systemCounts[s] ?? 0),
                    maxLines: 1,
                    style: TextStyle(fontSize: 11.5, color: AnatomoColors.muted),
                  ),
                ],
              ),
            ),
        ],
      ));
    }
    if (_system != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: InputChip(
            label: Text(content.systemName(_system!)),
            avatar: CircleAvatar(backgroundColor: systemColor(_system!), radius: 6),
            onDeleted: () => setState(() => _system = null),
            backgroundColor: AnatomoColors.tint,
            side: BorderSide.none,
          ),
        ),
      ));
    }
    for (final layer in layersPresent) {
      final inLayer = keys.where((k) => manifest.keyLayers[k] == layer).toList();
      if (inLayer.isEmpty) continue;
      children.add(SectionTitle(names[layer] ?? layer));
      children.add(Panel(
        child: Column(
          children: [
            for (var i = 0; i < inLayer.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _Row(
                letterColor: Color(manifest.keyColors[inLayer[i]] ?? 0xFF46BFB4),
                title: content.nameOf(inLayer[i]),
                subtitle: content[inLayer[i]] == null
                    ? null
                    : content.systemName(content[inLayer[i]]!.system),
                favorite: favorites.contains(inLayer[i]),
                onTap: () => widget.onOpenPart(inLayer[i], null, null),
              ),
            ],
          ],
        ),
      ));
    }
    if (detailed.isNotEmpty) {
      children.add(SectionTitle(t.detailedStructures));
      children.add(Panel(
        child: Column(
          children: [
            for (var i = 0; i < detailed.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _Row(
                letterColor: Color(manifest.keyColors[detailed[i].key] ?? 0xFF46BFB4),
                title: detailed[i].name,
                subtitle: content.nameOf(detailed[i].key),
                favorite: false,
                onTap: () => widget.onOpenPart(
                  detailed[i].key,
                  detailed[i].id,
                  detailed[i].name,
                ),
              ),
            ],
          ],
        ),
      ));
    }
    if (keys.isEmpty && detailed.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          _filter == 'fav' && q.isEmpty
              ? t.noFavorites
              : t.noResults(_query.text.trim()),
          textAlign: TextAlign.center,
          style: TextStyle(color: AnatomoColors.muted, fontSize: 15),
        ),
      ));
    }

    return ColoredBox(
      color: AnatomoColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(
              title: t.allParts,
              subtitle: '${manifest.sex == 'female' ? t.female : t.male} · '
                  '${t.partsCount(manifest.parts.length)}',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _query,
                focusNode: _focus,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: t.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: t.close,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(_query.clear),
                        ),
                  filled: true,
                  fillColor: AnatomoColors.panel,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AnatomoColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AnatomoColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AnatomoColors.accent, width: 1.5),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip(t.filterAll, 'all'),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ToggleChip(
                      label: t.favorites,
                      on: _filter == 'fav',
                      leading: Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: _filter == 'fav' ? AnatomoColors.bg : AnatomoColors.coral,
                      ),
                      onTap: () => setState(() => _filter = 'fav'),
                    ),
                  ),
                  for (final l in layersPresent) _chip(names[l] ?? l, l),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ToggleChip(
        label: label,
        on: _filter == value,
        onTap: () => setState(() => _filter = value),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.letterColor,
    required this.title,
    required this.subtitle,
    required this.favorite,
    required this.onTap,
  });

  final Color letterColor;
  final String title;
  final String? subtitle;
  final bool favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              LetterTile(text: title, color: letterColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
                      ),
                  ],
                ),
              ),
              if (favorite)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: Icon(Icons.star_rounded, size: 18, color: AnatomoColors.coral),
                ),
              Icon(Icons.chevron_right_rounded, color: AnatomoColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnatomoColors.panel2,
        border: Border.all(color: AnatomoColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AnatomoColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, height: 1.4, color: AnatomoColors.body),
            ),
          ),
        ],
      ),
    );
  }
}
