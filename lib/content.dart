import 'dart:convert';

import 'package:flutter/services.dart';

/// Texts for one body part (a "key" such as heart, liver or femur).
class PartContent {
  const PartContent({
    required this.name,
    required this.system,
    required this.description,
    required this.good,
    required this.bad,
    required this.facts,
  });

  final String name;

  /// Id of the body system, for example "circulatory".
  final String system;
  final String description;
  final List<String> good;
  final List<String> bad;

  /// Pairs of label and value.
  final List<List<String>> facts;

  static PartContent fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? v) =>
        v is List ? v.map((e) => '$e').toList() : const <String>[];
    final facts = <List<String>>[];
    final rawFacts = json['facts'];
    if (rawFacts is List) {
      for (final f in rawFacts) {
        if (f is List && f.length == 2) facts.add(['${f[0]}', '${f[1]}']);
      }
    }
    return PartContent(
      name: '${json['name'] ?? ''}',
      system: '${json['system'] ?? ''}',
      description: '${json['desc'] ?? ''}',
      good: strings(json['good']),
      bad: strings(json['bad']),
      facts: facts,
    );
  }
}

/// All part texts and body system names in one language.
class BodyContent {
  const BodyContent(this.parts, this.systems);

  final Map<String, PartContent> parts;
  final Map<String, String> systems;

  static const BodyContent empty = BodyContent({}, {});

  PartContent? operator [](String key) => parts[key];

  String systemName(String id) => systems[id] ?? id;

  /// Name of a key, or a readable fallback.
  String nameOf(String key) =>
      parts[key]?.name ?? key.replaceAll('_', ' ');

  static final Map<String, BodyContent> _cache = {};

  /// Loads the texts for [language]. Anything missing falls back to English.
  static Future<BodyContent> load(String language) async {
    final cached = _cache[language];
    if (cached != null) return cached;
    final english = await _read('en');
    if (language == 'en') {
      _cache['en'] = english;
      return english;
    }
    BodyContent local;
    try {
      local = await _read(language);
    } catch (_) {
      local = BodyContent.empty;
    }
    final merged = BodyContent(
      {...english.parts, ...local.parts},
      {...english.systems, ...local.systems},
    );
    _cache[language] = merged;
    return merged;
  }

  static Future<BodyContent> _read(String language) async {
    final parts = <String, PartContent>{};
    final systems = <String, String>{};
    for (final file in ['a', 'b']) {
      final text =
          await rootBundle.loadString('assets/content/${language}_$file.json');
      final data = jsonDecode(text) as Map<String, dynamic>;
      final sys = data['systems'];
      if (sys is Map) {
        sys.forEach((k, v) => systems['$k'] = '$v');
      }
      final keys = data['parts'];
      if (keys is Map) {
        keys.forEach((k, v) {
          if (v is Map<String, dynamic>) parts['$k'] = PartContent.fromJson(v);
        });
      }
    }
    return BodyContent(parts, systems);
  }
}
