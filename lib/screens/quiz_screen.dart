import 'dart:math';

import 'package:flutter/material.dart';

import '../content.dart';
import '../l10n/app_localizations.dart';
import '../quiz.dart';
import '../settings.dart';
import '../theme.dart';

/// A short quiz made from the part texts: ten questions, one score.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.content, required this.settings});

  final BodyContent content;
  final AppSettings settings;

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

  @override
  void initState() {
    super.initState();
    _questions = buildQuiz(widget.content, _random);
  }

  void _restart() {
    setState(() {
      _questions = buildQuiz(widget.content, _random);
      _index = 0;
      _picked = null;
      _score = 0;
      _done = false;
    });
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.quiz,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: _questions.isEmpty
          ? Center(child: Text(t.noResults('')))
          : _done
              ? _result(t)
              : _question(t),
    );
  }

  Widget _question(AppLocalizations t) {
    final q = _questions[_index];
    final picked = _picked;
    final prompt = q.kind == QuizKind.part
        ? t.quizWhichPart
        : t.quizWhichSystem(q.subject);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(
          t.quizQuestionOf(_index + 1, _questions.length),
          style: TextStyle(fontSize: 12.5, color: AnatomoColors.muted),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (_index + (picked == null ? 0 : 1)) / _questions.length,
            minHeight: 5,
            color: AnatomoColors.accent,
            backgroundColor: AnatomoColors.line,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          prompt,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        if (q.kind == QuizKind.part) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AnatomoColors.panel,
              border: Border.all(color: AnatomoColors.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              q.subject,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.5,
                color: AnatomoColors.body,
              ),
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
            picked == q.answer
                ? t.quizCorrect
                : t.quizWrong(q.options[q.answer]),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: picked == q.answer ? AnatomoColors.good : AnatomoColors.bad,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AnatomoColors.accent,
                foregroundColor: AnatomoColors.accentInk,
              ),
              onPressed: _next,
              child: Text(
                _index + 1 >= _questions.length ? t.quizFinish : t.quizNext,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
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
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AnatomoColors.accent,
                  foregroundColor: AnatomoColors.accentInk,
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
    switch (state) {
      case _OptionState.correct:
        border = AnatomoColors.good;
        fill = AnatomoColors.good.withAlpha(36);
      case _OptionState.wrong:
        border = AnatomoColors.bad;
        fill = AnatomoColors.bad.withAlpha(36);
      default:
        border = AnatomoColors.line;
        fill = AnatomoColors.panel;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: state == _OptionState.dim ? 0.55 : 1,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border, width: state == _OptionState.idle ? 1 : 1.6),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: state == _OptionState.idle ? onTap : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
