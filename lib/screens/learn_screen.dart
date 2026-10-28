import 'package:flutter/material.dart';

import '../atlas/part_picture.dart';
import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../quiz.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'flashcards_screen.dart';
import 'quiz_screen.dart';

/// The organ shown as "organ of the day": the same all day, a new one each
/// day, from the organs of [manifest] that have texts.
String? organOfTheDay(BodyManifest? manifest, BodyContent content, DateTime now) {
  if (manifest == null) return null;
  final seen = {for (final p in manifest.parts) if (p.visible) p.key};
  final organs = manifest.keyLayers.entries
      .where((e) =>
          e.value == 'organs' &&
          seen.contains(e.key) &&
          (manifest.keyWhole[e.key] ?? false) &&
          content[e.key] != null)
      .map((e) => e.key)
      .toList()
    ..sort();
  if (organs.isEmpty) return null;
  final day = DateTime.utc(now.year, now.month, now.day)
      .difference(DateTime.utc(2024, 1, 1))
      .inDays;
  return organs[day % organs.length];
}

/// The Learn tab: organ of the day, quizzes, flashcards and progress.
class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.settings,
    required this.content,
    required this.manifest,
    required this.onOpenPart,
  });

  final AppSettings settings;
  final BodyContent content;
  final BodyManifest? manifest;
  final void Function(String key, String? partId, String? pieceName) onOpenPart;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_changed);
  }

  @override
  void dispose() {
    widget.settings.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _quiz(QuizMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          content: widget.content,
          settings: widget.settings,
          manifest: widget.manifest,
          mode: mode,
        ),
      ),
    );
  }

  void _flashcards() {
    final m = widget.manifest;
    if (m == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardsScreen(
          content: widget.content,
          settings: widget.settings,
          manifest: m,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final m = widget.manifest;
    final content = widget.content;
    final settings = widget.settings;
    final today = organOfTheDay(m, content, DateTime.now());
    final total = m == null
        ? 0
        : m.keyLayers.keys.where((k) => content[k] != null).length;
    final studied = m == null
        ? 0
        : settings.studied.where((k) => m.keyLayers.containsKey(k)).length;

    return ColoredBox(
      color: AnatomoColors.bg,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageTitle(title: t.learn, subtitle: t.learnSubtitle),
            if (today != null && m != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _TodayCard(
                  manifest: m,
                  partKey: today,
                  name: content.nameOf(today),
                  text: content[today]?.description ?? '',
                  label: t.organOfDay,
                  more: t.readMore,
                  onTap: () => widget.onOpenPart(today, null, null),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
                children: [
                  _ModeTile(
                    icon: Icons.quiz_outlined,
                    tint: AnatomoColors.tint,
                    ink: AnatomoColors.accent,
                    title: t.quiz,
                    note: t.quizNote,
                    onTap: () => _quiz(QuizMode.mixed),
                  ),
                  _ModeTile(
                    icon: Icons.style_outlined,
                    tint: AnatomoColors.badTint,
                    ink: AnatomoColors.bad,
                    title: t.flashcards,
                    note: t.flashcardsNote,
                    onTap: _flashcards,
                  ),
                  _ModeTile(
                    icon: Icons.ads_click_rounded,
                    tint: const Color(0x223D6FC4),
                    ink: const Color(0xFF3D6FC4),
                    title: t.findPart,
                    note: t.findPartNote,
                    onTap: () => _quiz(QuizMode.find),
                  ),
                  _ModeTile(
                    icon: Icons.layers_outlined,
                    tint: const Color(0x22B0832A),
                    ink: const Color(0xFFB0832A),
                    title: t.systemsQuiz,
                    note: t.systemsQuizNote,
                    onTap: () => _quiz(QuizMode.systems),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Panel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.yourProgress,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.partsStudied,
                            style: TextStyle(fontSize: 13.5, color: AnatomoColors.body),
                          ),
                        ),
                        Text(
                          t.studiedOf(studied, total),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : studied / total,
                        minHeight: 8,
                        color: AnatomoColors.accent,
                        backgroundColor: AnatomoColors.line,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(label: t.bestQuiz, value: '${settings.quizBest} / 10'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Stat(
                            label: t.favorites,
                            value: '${settings.favorites.length}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.manifest,
    required this.partKey,
    required this.name,
    required this.text,
    required this.label,
    required this.more,
    required this.onTap,
  });

  final BodyManifest manifest;
  final String partKey;
  final String name;
  final String text;
  final String label;
  final String more;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Panel(
      color: AnatomoColors.text,
      radius: 22,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 136,
            decoration: BoxDecoration(
              color: AnatomoColors.picture,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: PartPicture(manifest: manifest, partKey: partKey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AnatomoColors.coral,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AnatomoColors.bg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AnatomoColors.bg.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$more →',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AnatomoColors.isLight
                        ? const Color(0xFF6FDCCB)
                        : AnatomoColors.deepTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.tint,
    required this.ink,
    required this.title,
    required this.note,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color ink;
  final String title;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: ink, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AnatomoColors.panel2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AnatomoColors.muted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
