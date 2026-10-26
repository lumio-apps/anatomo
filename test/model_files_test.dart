import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final sex in ['male', 'female']) {
    test('$sex model chunks are split by layer and all exist', () {
      final dir = 'assets/models/$sex';
      final man = jsonDecode(File('$dir/manifest.json').readAsStringSync())
          as Map<String, dynamic>;
      final chunks = (man['chunks'] as List).cast<String>();
      final layers = (man['chunkLayers'] as List).cast<String>();
      expect(layers.length, chunks.length);
      for (final c in chunks) {
        expect(File('$dir/$c').existsSync(), isTrue, reason: c);
      }
      final fields = (man['fields'] as List).cast<String>();
      final chunkAt = fields.indexOf('chunk');
      final keyAt = fields.indexOf('key');
      final keys = man['keys'] as Map<String, dynamic>;
      for (final row in man['parts'] as List) {
        final r = row as List;
        final layer = (keys[r[keyAt]] as Map)['layer'];
        expect(layers[r[chunkAt] as int], layer);
      }
    });
  }
}
