import 'dart:math';

import 'content.dart';

enum QuizKind { part, system }

class QuizQuestion {
  const QuizQuestion({
    required this.kind,
    required this.subject,
    required this.options,
    required this.answer,
  });

  final QuizKind kind;

  /// The description of a part ([QuizKind.part]) or the name of a part
  /// ([QuizKind.system]).
  final String subject;
  final List<String> options;

  /// Index of the right option.
  final int answer;
}

bool _leaks(PartContent c) {
  final name = c.name.toLowerCase();
  return name.length >= 3 && c.description.toLowerCase().contains(name);
}

/// Four options with the right one at a random place, or null when there are
/// not enough different wrong answers.
({List<String> options, int answer})? _options(
  String correct,
  Iterable<String> pool,
  Random random,
) {
  final wrong = pool.where((s) => s != correct).toSet().toList()..shuffle(random);
  if (wrong.length < 3) return null;
  final options = [...wrong.take(3), correct]..shuffle(random);
  return (options: options, answer: options.indexOf(correct));
}

/// Builds a round of questions from the texts that are already in the app, in
/// the language of [content]: "which part is this?" and "which system?".
List<QuizQuestion> buildQuiz(BodyContent content, Random random, {int count = 10}) {
  final keys = content.parts.keys
      .where((k) =>
          content[k]!.name.isNotEmpty && content[k]!.description.isNotEmpty)
      .toList()
    ..shuffle(random);
  if (keys.length < 8) return const [];

  final names = keys.map((k) => content[k]!.name).toList();
  final systems = content.systems.values.toList();
  final clean = keys.where((k) => !_leaks(content[k]!)).toList();
  final leaky = keys.where((k) => _leaks(content[k]!)).toList();
  final partOrder = [...clean, ...leaky];

  QuizQuestion? partQuestion(String k) {
    final c = content[k]!;
    final o = _options(c.name, names, random);
    if (o == null) return null;
    return QuizQuestion(
      kind: QuizKind.part,
      subject: c.description,
      options: o.options,
      answer: o.answer,
    );
  }

  QuizQuestion? systemQuestion(String k) {
    final c = content[k]!;
    final systemName = content.systems[c.system];
    if (systemName == null) return null;
    final o = _options(systemName, systems, random);
    if (o == null) return null;
    return QuizQuestion(
      kind: QuizKind.system,
      subject: c.name,
      options: o.options,
      answer: o.answer,
    );
  }

  final questions = <QuizQuestion>[];
  final used = <String>{};
  final partCount = (count * 0.6).round();
  for (final k in partOrder) {
    if (questions.length >= partCount) break;
    final q = partQuestion(k);
    if (q != null) {
      questions.add(q);
      used.add(k);
    }
  }
  for (final k in keys) {
    if (questions.length >= count) break;
    if (used.contains(k)) continue;
    final q = systemQuestion(k);
    if (q != null) {
      questions.add(q);
      used.add(k);
    }
  }
  for (final k in partOrder) {
    if (questions.length >= count) break;
    if (used.contains(k)) continue;
    final q = partQuestion(k);
    if (q != null) {
      questions.add(q);
      used.add(k);
    }
  }
  questions.shuffle(random);
  return questions;
}
