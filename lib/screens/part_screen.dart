import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../atlas/part_picture.dart';
import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../layer_names.dart';
import '../pack/pack3d.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'quiz_screen.dart';

/// What the part page asks the app to do when it closes.
class PartResult {
  const PartResult(this.key, {this.partId, this.in3d = false});

  /// Show this part on the body.
  final String key;
  final String? partId;

  /// Show it in the 3D view.
  final bool in3d;
}

/// Everything about one part on one page: where it is, what it does, what is
/// good for it and what harms it, its pieces and the parts it works with.
class PartScreen extends StatefulWidget {
  const PartScreen({
    super.key,
    required this.settings,
    required this.content,
    required this.manifest,
    required this.links,
    required this.partKey,
    this.partId,
    this.pieceName,
  });

  final AppSettings settings;
  final BodyContent content;
  final BodyManifest manifest;
  final Map<String, List<String>> links;
  final String partKey;

  /// Set when one exact piece (one muscle, one bone, ...) was opened.
  final String? partId;
  final String? pieceName;

  @override
  State<PartScreen> createState() => _PartScreenState();
}

class _PartScreenState extends State<PartScreen> {
  bool _allPieces = false;

  String get _key => widget.partKey;

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_changed);
    // After the first frame: saving notifies the whole app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.settings.markStudied(_key);
    });
  }

  @override
  void dispose() {
    widget.settings.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _openOther(String key) async {
    final result = await Navigator.of(context).push<PartResult>(
      MaterialPageRoute(
        builder: (_) => PartScreen(
          settings: widget.settings,
          content: widget.content,
          manifest: widget.manifest,
          links: widget.links,
          partKey: key,
        ),
      ),
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  void _show({String? partId, bool in3d = false}) {
    Navigator.of(context).pop(
      PartResult(_key, partId: partId ?? widget.partId, in3d: in3d),
    );
  }

  Future<void> _copy() async {
    final t = AppLocalizations.of(context);
    final content = widget.content;
    final info = content[_key];
    final buffer = StringBuffer(content.nameOf(_key));
    if (info != null) {
      buffer
        ..writeln(' (${content.systemName(info.system)})')
        ..writeln(info.description);
      final where = content.whereOf(_key);
      if (where != null) {
        buffer
          ..writeln()
          ..writeln('${t.whereItIs}: $where');
      }
      buffer
        ..writeln()
        ..writeln('+ ${t.tabGood}')
        ..writeAll(info.good.map((s) => '  - $s\n'))
        ..writeln()
        ..writeln('- ${t.tabBad}')
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

  void _quiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          content: widget.content,
          settings: widget.settings,
          manifest: widget.manifest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final content = widget.content;
    final m = widget.manifest;
    final info = content[_key];
    final layer = m.keyLayers[_key];
    final favorite = widget.settings.favorites.contains(_key);
    final fitted = m.fittedKeys.contains(_key);
    final where = content.whereOf(_key);
    final pieces = <String>{
      for (final p in m.partsOf(_key)) p.name,
    }.toList()
      ..sort();
    final shownPieces = _allPieces ? pieces : pieces.take(5).toList();
    final linked = (widget.links[_key] ?? const <String>[])
        .where((k) => m.keyLayers.containsKey(k))
        .toList();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AnatomoColors.bg,
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + bottom),
        children: [
          // ---- picture
          Stack(
            children: [
              Container(
                height: 300 + MediaQuery.paddingOf(context).top,
                color: AnatomoColors.picture,
                padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 40),
                child: PartPicture(
                  manifest: m,
                  partKey: _key,
                  partId: widget.partId,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: MediaQuery.paddingOf(context).top + 8,
                child: Row(
                  children: [
                    SquareButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      filled: true,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    SquareButton(
                      icon: Icons.copy_rounded,
                      tooltip: t.copyText,
                      filled: true,
                      onTap: _copy,
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: favorite ? t.removeFavorite : t.addFavorite,
                      child: Material(
                        color: AnatomoColors.panel,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => widget.settings.toggleFavorite(_key),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: favorite ? AnatomoColors.coral : AnatomoColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (Pack3D.supported)
                PositionedDirectional(
                  end: 14,
                  bottom: 30,
                  child: Material(
                    color: AnatomoColors.text,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => _show(in3d: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.view_in_ar_rounded, size: 18, color: AnatomoColors.bg),
                            const SizedBox(width: 8),
                            Text(
                              t.viewIn3d,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AnatomoColors.bg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // ---- texts
          Transform.translate(
            offset: const Offset(0, -18),
            child: Container(
              decoration: BoxDecoration(
                color: AnatomoColors.bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (info != null)
                        _Tag(
                          text: content.systemName(info.system),
                          dot: systemColor(info.system),
                        ),
                      if (layer != null) _Tag(text: layerNames(t)[layer] ?? layer),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content.nameOf(_key),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.15,
                    ),
                  ),
                  if (widget.pieceName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      t.partLabel(widget.pieceName!),
                      style: TextStyle(fontSize: 14, color: AnatomoColors.muted),
                    ),
                  ],
                  if (fitted) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: AnatomoColors.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            m.sex == 'female' ? t.fittedFromMale : t.fittedFromFemale,
                            style: TextStyle(fontSize: 12.5, height: 1.4, color: AnatomoColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (info != null && info.facts.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, c) {
                        final w = (c.maxWidth - 10) / 2;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final f in info.facts)
                              SizedBox(
                                width: w,
                                child: Panel(
                                  radius: 16,
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f[0],
                                        style: TextStyle(fontSize: 12, color: AnatomoColors.muted),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        f[1],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                  if (info != null) ...[
                    _Heading(t.tabAbout),
                    Text(
                      info.description,
                      style: TextStyle(fontSize: 15.5, height: 1.6, color: AnatomoColors.body),
                    ),
                  ],
                  if (where != null) ...[
                    const SizedBox(height: 20),
                    Panel(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 78,
                            height: 160,
                            decoration: BoxDecoration(
                              color: AnatomoColors.picture,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: PartPicture(
                              manifest: m,
                              partKey: _key,
                              partId: widget.partId,
                              focus: false,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.whereItIs,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  where,
                                  style: TextStyle(fontSize: 14.5, height: 1.55, color: AnatomoColors.body),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    foregroundColor: AnatomoColors.accent,
                                  ),
                                  onPressed: () => _show(),
                                  child: Text(
                                    '${t.showOnBody} →',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (info != null && info.good.isNotEmpty) ...[
                    _Heading(t.tabGood),
                    for (final item in info.good) _Point(text: item, good: true),
                  ],
                  if (info != null && info.bad.isNotEmpty) ...[
                    _Heading(t.tabBad),
                    for (final item in info.bad) _Point(text: item, good: false),
                  ],
                  if (pieces.length > 1) ...[
                    _Heading(t.madeOfPieces(pieces.length)),
                    Panel(
                      radius: 16,
                      child: Column(
                        children: [
                          for (var i = 0; i < shownPieces.length; i++) ...[
                            if (i > 0) const Divider(height: 1),
                            _PieceRow(
                              name: shownPieces[i],
                              color: Color(m.keyColors[_key] ?? 0xFF46BFB4),
                              onTap: () {
                                final name = shownPieces[i];
                                for (final p in m.partsOf(_key)) {
                                  if (p.name == name) {
                                    _show(partId: p.id);
                                    return;
                                  }
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (pieces.length > 5)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          style: TextButton.styleFrom(foregroundColor: AnatomoColors.accent),
                          onPressed: () => setState(() => _allPieces = !_allPieces),
                          child: Text(
                            _allPieces ? t.showLess : t.showAll,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                  if (linked.isNotEmpty) ...[
                    _Heading(t.worksWith),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final k in linked)
                          ActionChip(
                            label: Text(content.nameOf(k)),
                            labelStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AnatomoColors.text,
                            ),
                            backgroundColor: AnatomoColors.panel,
                            side: BorderSide(color: AnatomoColors.line),
                            shape: const StadiumBorder(),
                            onPressed: () => _openOther(k),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AnatomoColors.text,
                        foregroundColor: AnatomoColors.bg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _quiz,
                      icon: const Icon(Icons.quiz_outlined),
                      label: Text(
                        t.quizMe,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      t.notMedical,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AnatomoColors.muted),
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

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.dot});

  final String text;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AnatomoColors.panel2,
        border: Border.all(color: AnatomoColors.line),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AnatomoColors.body),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.text, required this.good});

  final String text;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Panel(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: good ? AnatomoColors.goodTint : AnatomoColors.badTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                good ? Icons.check_rounded : Icons.close_rounded,
                size: 16,
                color: good ? AnatomoColors.good : AnatomoColors.bad,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 15, height: 1.45, color: AnatomoColors.body),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieceRow extends StatelessWidget {
  const _PieceRow({required this.name, required this.color, required this.onTap});

  final String name;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: const TextStyle(fontSize: 14.5))),
              Icon(Icons.chevron_right_rounded, color: AnatomoColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
