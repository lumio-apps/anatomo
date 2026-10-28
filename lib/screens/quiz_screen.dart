import 'dart:math';

import 'package:flutter/material.dart';

import '../atlas/atlas_controller.dart';
import '../atlas/atlas_view.dart';
import '../atlas/part_picture.dart';
import '../body_manifest.dart';
import '../content.dart';
import '../l10n/app_localizations.dart';
import '../quiz.dart';
import '../selection.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Parts that can be shown as a picture or found on the body: whole organs,
/// bones and muscles.
Set<String> quizPictureKeys(BodyManifest? m) {
  if (m == null) return const {};
  // Keys with at least one piece that can be seen in the 2D pictures.
  final seen = {for (final p in m.parts) if (p.visible) p.key};
  return {
    for (final e in m.keyLayers.entries)
      if ((m.keyWhole[e.key] ?? false) &&
          seen.contains(e.key) &&
          const ['organs', 'bones', 'muscles'].contains(e.value))
        e.key,
  };
}

/// A short quiz made from the part texts: ten questions, one score.
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.content,
    required this.settings,
    required this.manifest,
    this.mode = QuizMode.mixed,
  });

  final BodyContent content;
  final AppSettings settings;
  final BodyManifest? manifest;
  final QuizMode mode;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _random = Random();
  late List<QuizQuestion> _questions;
  int _index = 0;
  int? _picked;
  int _score = 0;
  bool _done = false;

  // "Find the part"
  AtlasController? _atlas;
  String _view = 'front';
  bool? _foundRight;

  @override
  void initState() {
    super.initState();
    _questions = _build();
    final m = widget.manifest;
    if (widget.mode == QuizMode.find && m != null) {
      final atlas = AtlasController(
        onSelect: _onFindSelect,
        onClear: () {},
        onLayers: (_) {},
        layers: const {},
      );
      atlas.setManifest(m);
      _atlas = atlas;
      _prepareFind();
    }
  }

  @override
  void dispose() {
    _atlas?.dispose();
    super.dispose();
  }

  List<QuizQuestion> _build() {
    final keys = quizPictureKeys(widget.manifest);
    return switch (widget.mode) {
      QuizMode.find => buildFindQuiz(widget.content, keys, _random),
      QuizMode.systems => buildQuiz(widget.content, _random, systemsOnly: true),
      QuizMode.mixed => buildQuiz(widget.content, _random, pictureKeys: keys),
    };
  }

  void _restart() {
    setState(() {
      _questions = _build();
      _index = 0;
      _picked = null;
      _foundRight = null;
      _score = 0;
      _done = false;
    });
    _prepareFind();
  }

  void _pick(int i) {
    if (_picked != null) return;
    setState(() {
      _picked = i;
      if (i == _questions[_index].answer) _score++;
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      widget.settings.setQuizBest(_score);
      setState(() => _done = true);
    } else {
      setState(() {
        _index++;
        _picked = null;
        _foundRight = null;
      });
      _prepareFind();
    }
  }

  /// Shows only the layer of the part to find, from the front.
  void _prepareFind() {
    final atlas = _atlas;
    final m = widget.manifest;
    if (atlas == null || m == null || _questions.isEmpty) return;
    final layer = m.keyLayers[_questions[_index].key] ?? 'organs';
    atlas.setLayers({for (final l in kLayers) l: l == layer});
    atlas.reset();
    _view = 'front';
  }

  void _onFindSelect(ViewerSelection selection) {
    if (_foundRight != null || _done || _questions.isEmpty) return;
    final target = _questions[_index].key;
    final right = selection.key == target;
    setState(() {
      _foundRight = right;
      if (right) _score++;
    });
    // Show where the right part is.
    if (!right) _atlas?.selectKey(target);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title(t),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: _questions.isEmpty
          ? Center(child: Text(t.noResults('')))
          : _done
              ? _result(t)
              : widget.mode == QuizMode.find
                  ? _find(t)
                  : _question(t),
    );
  }

  String _title(AppLocalizations t) => switch (widget.mode) {
        QuizMode.find => t.findPart,
        QuizMode.systems => t.systemsQuiz,
        QuizMode.mixed => t.quiz,
      };

  Widget _progress(AppLocalizations t, bool answered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quizQuestionOf(_index + 1, _questions.length),
          style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (_index + (answered ? 1 : 0)) / _questions.length,
            minHeight: 6,
            color: AnatomoColors.accent,
            backgroundColor: AnatomoColors.line,
          ),
        ),
      ],
    );
  }

  Widget _nextButton(AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AnatomoColors.text,
          foregroundColor: AnatomoColors.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _next,
        child: Text(
          _index + 1 >= _questions.length ? t.quizFinish : t.quizNext,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _question(AppLocalizations t) {
    final q = _questions[_index];
    final picked = _picked;
    final m = widget.manifest;
    final prompt = switch (q.kind) {
      QuizKind.part => t.quizWhichPart,
      QuizKind.system => t.quizWhichSystem(q.subject),
      QuizKind.picture || QuizKind.find => t.quizWhatHighlighted,
    };
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _progress(t, picked != null),
        const SizedBox(height: 16),
        if (q.kind == QuizKind.picture && m != null) ...[
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: AnatomoColors.picture,
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.antiAlias,
            child: PartPicture(manifest: m, partKey: q.key),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          prompt,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.3),
        ),
        if (q.kind == QuizKind.part) ...[
          const SizedBox(height: 12),
          Panel(
            radius: 16,
            padding: const EdgeInsets.all(14),
            child: Text(
              q.subject,
              style: TextStyle(fontSize: 15.5, height: 1.5, color: AnatomoColors.body),
            ),
          ),
        ],
        const SizedBox(height: 14),
        for (var i = 0; i < q.options.length; i++)
          _OptionTile(
            text: q.options[i],
            state: picked == null
                ? _OptionState.idle
                : i == q.answer
                    ? _OptionState.correct
                    : i == picked
                        ? _OptionState.wrong
                        : _OptionState.dim,
            onTap: () => _pick(i),
          ),
        if (picked != null) ...[
          const SizedBox(height: 6),
          Text(
            picked == q.answer ? t.quizCorrect : t.quizWrong(q.options[q.answer]),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: picked == q.answer ? AnatomoColors.good : AnatomoColors.bad,
            ),
          ),
          if (q.key.isNotEmpty && widget.content[q.key] != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.content[q.key]!.description,
              style: TextStyle(fontSize: 13.5, height: 1.5, color: AnatomoColors.muted),
            ),
          ],
          const SizedBox(height: 16),
          _nextButton(t),
        ],
      ],
    );
  }

  Widget _find(AppLocalizations t) {
    final q = _questions[_index];
    final atlas = _atlas;
    final right = _foundRight;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _progress(t, right != null),
          const SizedBox(height: 14),
          Text(
            t.quizTapThe(q.subject),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.3),
          ),
          const SizedBox(height: 4),
          Text(
            t.quizTapHint,
            style: TextStyle(fontSize: 13.5, color: AnatomoColors.muted),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  if (atlas != null) Positioned.fill(child: AtlasView(controller: atlas)),
                  PositionedDirectional(
                    start: 10,
                    top: 10,
                    child: Segmented(
                      vertical: true,
                      itemWidth: 60,
                      options: {
                        'front': t.viewFront,
                        'back': t.viewBack,
                        'side': t.viewSide,
                      },
                      value: _view,
                      onChanged: (v) {
                        setState(() => _view = v);
                        atlas?.setView(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (right != null) ...[
            const SizedBox(height: 12),
            Text(
              right ? t.quizCorrect : t.quizWrong(q.subject),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: right ? AnatomoColors.good : AnatomoColors.bad,
              ),
            ),
            const SizedBox(height: 12),
            _nextButton(t),
          ],
        ],
      ),
    );
  }

  Widget _result(AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, size: 64, color: AnatomoColors.coral),
            const SizedBox(height: 16),
            Text(
              t.quizScore(_score, _questions.length),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              t.quizBest(widget.settings.quizBest),
              style: TextStyle(fontSize: 14.5, color: AnatomoColors.muted),
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

enum _OptionState { idle, correct, wrong, dim }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    String mark = '';
    switch (state) {
      case _OptionState.correct:
        border = AnatomoColors.good;
        fill = AnatomoColors.goodTint;
        mark = '✓';
      case _OptionState.wrong:
        border = AnatomoColors.bad;
        fill = AnatomoColors.badTint;
        mark = '✕';
      default:
        border = AnatomoColors.line;
        fill = AnatomoColors.panel;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: state == _OptionState.dim ? 0.55 : 1,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: border, width: state == _OptionState.idle ? 1 : 1.6),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: state == _OptionState.idle ? onTap : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (mark.isNotEmpty)
                      Text(
                        mark,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: border,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
