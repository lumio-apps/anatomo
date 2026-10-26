import 'dart:convert';

import 'package:flutter/services.dart';

/// One piece of the body (one mesh of the 3D models).
class BodyPart {
  const BodyPart(
    this.id,
    this.name,
    this.key, {
    this.index = -1,
    this.visible = true,
  });

  final String id;

  /// Anatomical name, in English (from the source data).
  final String name;
  final String key;

  /// Position in the model. The 2D tap maps store this number plus one.
  final int index;

  /// Seen in at least one of the 2D pictures.
  final bool visible;
}

/// What the app knows about a body without drawing it: its keys (heart,
/// liver, ...) with their layers and colours, every part, and the sizes of
/// the 2D pictures. Read from `assets/atlas/<sex>/atlas.json`.
class BodyManifest {
  const BodyManifest(
    this.sex,
    this.keyLayers,
    this.keyColors,
    this.parts, {
    this.keyWhole = const {},
    this.fittedKeys = const {},
    this.pictureSizes = const {},
    this.tapMapSizes = const {},
  });

  final String sex;

  /// key -> layer (organs, bones, muscles, nerves, vessels, skin)
  final Map<String, String> keyLayers;

  /// key -> colour used for that key (as 0xAARRGGBB).
  final Map<String, int> keyColors;

  /// key -> true when a tap selects all pieces of the key together.
  final Map<String, bool> keyWhole;

  /// Keys whose pieces were adapted from the other body (see ATTRIBUTION.md).
  final Set<String> fittedKeys;

  /// view -> [width, height] of the colour pictures and of the tap maps.
  final Map<String, List<int>> pictureSizes;
  final Map<String, List<int>> tapMapSizes;

  final List<BodyPart> parts;

  static final Map<String, BodyManifest> _cache = {};

  static Future<BodyManifest> load(String sex) async {
    final cached = _cache[sex];
    if (cached != null) return cached;
    final text = await rootBundle.loadString('assets/atlas/$sex/atlas.json');
    final manifest = parse(sex, jsonDecode(text) as Map<String, dynamic>);
    _cache[sex] = manifest;
    return manifest;
  }

  static BodyManifest parse(String sex, Map<String, dynamic> data) {
    final fields = (data['fields'] as List).cast<String>();
    final iId = fields.indexOf('id');
    final iName = fields.indexOf('name');
    final iKey = fields.indexOf('key');
    final iVisible = fields.indexOf('visible');
    final layers = <String, String>{};
    final colors = <String, int>{};
    final whole = <String, bool>{};
    (data['keys'] as Map<String, dynamic>).forEach((k, v) {
      final info = v as Map;
      layers[k] = '${info['layer']}';
      whole[k] = info['whole'] == true;
      final hex = '${info['color']}'.replaceFirst('#', '');
      colors[k] = int.tryParse('FF$hex', radix: 16) ?? 0xFF46BFB4;
    });
    final parts = <BodyPart>[];
    final rows = data['parts'] as List;
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i] as List;
      parts.add(BodyPart(
        '${r[iId]}',
        '${r[iName]}',
        '${r[iKey]}',
        index: i,
        visible: iVisible < 0 || r[iVisible] == 1,
      ));
    }
    final pictures = <String, List<int>>{};
    final tapMaps = <String, List<int>>{};
    final views = data['views'];
    if (views is Map) {
      views.forEach((view, v) {
        final info = v as Map;
        pictures['$view'] = (info['size'] as List).cast<int>();
        tapMaps['$view'] = (info['ids'] as List).cast<int>();
      });
    }
    final fitted = data['fitted'];
    return BodyManifest(
      sex,
      layers,
      colors,
      parts,
      keyWhole: whole,
      fittedKeys: fitted is List ? fitted.map((e) => '$e').toSet() : const {},
      pictureSizes: pictures,
      tapMapSizes: tapMaps,
    );
  }

  /// The same body with only the parts that the 2D pictures show.
  BodyManifest visibleOnly() {
    final shown = parts.where((p) => p.visible).toList();
    final keys = shown.map((p) => p.key).toSet();
    return BodyManifest(
      sex,
      {
        for (final e in keyLayers.entries)
          if (keys.contains(e.key)) e.key: e.value,
      },
      keyColors,
      shown,
      keyWhole: keyWhole,
      fittedKeys: fittedKeys,
      pictureSizes: pictureSizes,
      tapMapSizes: tapMapSizes,
    );
  }

  /// All pieces of a key.
  List<BodyPart> partsOf(String key) =>
      parts.where((p) => p.key == key).toList();
}
