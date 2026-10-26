import 'package:flutter/material.dart';

import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../layer_names.dart';
import '../settings.dart';
import '../theme.dart';

/// What the user picked in the parts list.
class PartsPick {
  const PartsPick(this.key, [this.partId]);

  final String key;

  /// Set when one exact piece was picked from the detailed list.
  final String? partId;
}

/// Search and browse every part of the body.
class PartsScreen extends StatefulWidget {
  const PartsScreen({
    super.key,
    required this.manifest,
    required this.content,
    required this.sex,
  });

  final BodyManifest manifest;
  final BodyContent content;
  final String sex;

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final TextEditingController _query = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final names = layerNames(t);
    final content = widget.content;
    final manifest = widget.manifest;
    final q = _query.text.trim().toLowerCase();

    final keys = manifest.keyLayers.keys.where((k) {
      if (_filter != 'all' && manifest.keyLayers[k] != _filter) return false;
      if (q.isEmpty) return true;
      final info = content[k];
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

    final children = <Widget>[];
    if (widget.sex == 'female') {
      children.add(_Note(text: t.femaleNote));
    }
    for (final layer in layersPresent) {
      final inLayer = keys.where((k) => manifest.keyLayers[k] == layer).toList();
      if (inLayer.isEmpty) continue;
      children.add(_Header(names[layer] ?? layer));
      for (final k in inLayer) {
        final info = content[k];
        children.add(_Row(
          color: Color(manifest.keyColors[k] ?? 0xFF46BFB4),
          title: content.nameOf(k),
          subtitle: info == null ? null : content.systemName(info.system),
          onTap: () => Navigator.of(context).pop(PartsPick(k)),
        ));
      }
    }
    if (detailed.isNotEmpty) {
      children.add(_Header(t.detailedStructures));
      for (final p in detailed) {
        children.add(_Row(
          color: Color(manifest.keyColors[p.key] ?? 0xFF46BFB4),
          title: p.name,
          subtitle: content.nameOf(p.key),
          onTap: () => Navigator.of(context).pop(PartsPick(p.key, p.id)),
        ));
      }
    }
    if (keys.isEmpty && detailed.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          t.noResults(_query.text.trim()),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AnatomoColors.muted, fontSize: 15),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.allParts,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              '${widget.sex == 'female' ? t.female : t.male} · '
              '${t.partsCount(manifest.parts.length)}',
              style: const TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _query,
              autofocus: false,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AnatomoColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AnatomoColors.line),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: t.filterAll,
                  selected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                for (final l in layersPresent)
                  _FilterChip(
                    label: names[l] ?? l,
                    selected: _filter == l,
                    onTap: () => setState(() => _filter = l),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AnatomoColors.muted,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AnatomoColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AnatomoColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AnatomoColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AnatomoColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Material(
        color: selected ? AnatomoColors.text : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AnatomoColors.text : AnatomoColors.line,
          ),
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
                  color: selected ? AnatomoColors.bg : AnatomoColors.body,
                ),
              ),
            ),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AnatomoColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.4, color: AnatomoColors.body),
            ),
          ),
        ],
      ),
    );
  }
}
