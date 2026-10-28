import 'dart:math';

import 'package:flutter/material.dart';

import '../atlas/part_picture.dart';
import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../settings.dart';
import '../theme.dart';
import 'quiz_screen.dart';

/// Flashcards: a highlighted part on the front, its name and what it does on
/// the back. "Again" puts the card at the end of the pile.
class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    required this.content,
    required this.settings,
    required this.manifest,
  });

  final BodyContent content;
  final AppSettings settings;
  final BodyManifest manifest;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  static const int _deckSize = 20;
  final Random _random = Random();
  late List<String> _deck;
  int _learned = 0;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _deck = _newDeck();
  }

  List<String> _newDeck() {
    final keys = quizPictureKeys(widget.manifest)
        .where((k) => widget.content[k] != null)
        .toList()
      ..shuffle(_random);
    return keys.take(_deckSize).toList();
  }

  void _restart() {
    setState(() {
      _deck = _newDeck();
      _learned = 0;
      _flipped = false;
    });
  }

  void _gotIt() {
    final key = _deck.removeAt(0);
    widget.settings.markStudied(key);
    setState(() {
      _learned++;
      _flipped = false;
    });
  }

  void _again() {
    final key = _deck.removeAt(0);
    _deck.add(key);
    setState(() => _flipped = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.flashcards,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: _deck.isEmpty ? _done(t) : _card(t),
    );
  }

  Widget _card(AppLocalizations t) {
    final key = _deck.first;
    final content = widget.content;
    final info = content[key];
    final total = _learned + _deck.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.studiedOf(_learned, total),
            style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : _learned / total,
              minHeight: 6,
              color: AnatomoColors.accent,
              backgroundColor: AnatomoColors.line,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Material(
              color: AnatomoColors.panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: AnatomoColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => setState(() => _flipped = !_flipped),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _flipped
                      ? _back(key, info, content, t)
                      : _front(key, t),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_flipped)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AnatomoColors.text,
                        side: BorderSide(color: AnatomoColors.line),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _again,
                      child: Text(
                        t.flashAgain,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AnatomoColors.text,
                        foregroundColor: AnatomoColors.bg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _gotIt,
                      child: Text(
                        t.flashGotIt,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              height: 52,
              child: Center(
                child: Text(
                  t.flashTapToFlip,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AnatomoColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _front(String key, AppLocalizations t) {
    return Column(
      key: ValueKey('front-$key'),
      children: [
        Expanded(
          child: Container(
            color: AnatomoColors.picture,
            child: PartPicture(manifest: widget.manifest, partKey: key),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            t.quizWhatHighlighted,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _back(String key, PartContent? info, BodyContent content, AppLocalizations t) {
    return SingleChildScrollView(
      key: ValueKey('back-$key'),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.nameOf(key),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6),
          ),
          if (info != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: systemColor(info.system),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  content.systemName(info.system),
                  style: TextStyle(fontSize: 14, color: AnatomoColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              info.description,
              style: TextStyle(fontSize: 16, height: 1.6, color: AnatomoColors.body),
            ),
          ],
          if (content.whereOf(key) != null) ...[
            const SizedBox(height: 16),
            Text(
              t.whereItIs,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              content.whereOf(key)!,
              style: TextStyle(fontSize: 14.5, height: 1.5, color: AnatomoColors.body),
            ),
          ],
        ],
      ),
    );
  }

  Widget _done(AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 64, color: AnatomoColors.accent),
            const SizedBox(height: 16),
            Text(
              t.flashDone(_learned),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AnatomoColors.text,
                  foregroundColor: AnatomoColors.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _restart,
                child: Text(
                  t.quizPlayAgain,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.close),
            ),
          ],
        ),
      ),
    );
  }
}
