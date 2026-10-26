import 'dart:convert';

import 'package:flutter/services.dart';

/// One mesh of the 3D body.
class BodyPart {
  const BodyPart(this.id, this.name, this.key);

  final String id;

  /// Anatomical name, in English (from the source data).
  final String name;
  final String key;
}

/// What the app needs to know about a 3D body without drawing it: which
/// keys (heart, liver, ...) it has, their layers, and all part names.
class BodyManifest {
  const BodyManifest(this.sex, this.keyLayers, this.keyColors, this.parts);

  final String sex;

  /// key -> layer (organs, bones, muscles, nerves, vessels, skin)
  final Map<String, String> keyLayers;

  /// key -> colour used for that key in the 3D view (as 0xAARRGGBB).
  final Map<String, int> keyColors;
  final List<BodyPart> parts;

  static final Map<String, BodyManifest> _cache = {};

  static Future<BodyManifest> load(String sex) async {
    final cached = _cache[sex];
    if (cached != null) return cached;
    final text = await rootBundle.loadString('assets/models/$sex/manifest.json');
    final data = jsonDecode(text) as Map<String, dynamic>;
    final fields = (data['fields'] as List).cast<String>();
    final iId = fields.indexOf('id');
    final iName = fields.indexOf('name');
    final iKey = fields.indexOf('key');
    final keys = <String, String>{};
    final colors = <String, int>{};
    (data['keys'] as Map<String, dynamic>).forEach((k, v) {
      final info = v as Map;
      keys[k] = '${info['layer']}';
      final hex = '${info['color']}'.replaceFirst('#', '');
      colors[k] = int.tryParse('FF$hex', radix: 16) ?? 0xFF46BFB4;
    });
    final parts = <BodyPart>[];
    for (final row in data['parts'] as List) {
      final r = row as List;
      parts.add(BodyPart('${r[iId]}', '${r[iName]}', '${r[iKey]}'));
    }
    final manifest = BodyManifest(sex, keys, colors, parts);
    _cache[sex] = manifest;
    return manifest;
  }
}
