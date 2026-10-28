import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// A tap map: every pixel holds the number of the part drawn there
/// (red + 256 * green; 0 = nothing).
class TapMap {
  TapMap(this.width, this.height, this.pixels);

  final int width;
  final int height;
  final Uint8List pixels; // RGBA

  int idAt(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return 0;
    final o = (y * width + x) * 4;
    return pixels[o] + pixels[o + 1] * 256;
  }

  /// The part at (x, y), or the most common part close to it, so thin
  /// pieces are easy to hit with a finger.
  int pick(int x, int y, int radius) {
    final exact = idAt(x, y);
    if (exact != 0) return exact;
    final count = <int, int>{};
    for (var dy = -radius; dy <= radius; dy++) {
      for (var dx = -radius; dx <= radius; dx++) {
        if (dx * dx + dy * dy > radius * radius) continue;
        final id = idAt(x + dx, y + dy);
        if (id != 0) count[id] = (count[id] ?? 0) + 1;
      }
    }
    if (count.isEmpty) return 0;
    return count.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

/// Decoded pictures and tap maps, shared by all screens. Only a few are kept,
/// so the memory stays low.
class AtlasImages {
  AtlasImages._();

  static final Map<String, Future<ui.Image>> _images = {};
  static final Map<String, Future<TapMap>> _maps = {};
  static const int _keep = 10;

  static Future<ui.Image> image(String asset) {
    final hit = _images.remove(asset);
    final future = hit ?? _decode(asset);
    _images[asset] = future; // most recent last
    while (_images.length > _keep) {
      _images.remove(_images.keys.first);
    }
    future.catchError((Object _) {
      _images.remove(asset);
      return Future<ui.Image>.error('missing');
    }).ignore();
    return future;
  }

  static Future<TapMap> map(String asset) {
    final hit = _maps.remove(asset);
    final future = hit ?? _decodeMap(asset);
    _maps[asset] = future;
    while (_maps.length > _keep) {
      _maps.remove(_maps.keys.first);
    }
    future.catchError((Object _) {
      _maps.remove(asset);
      return Future<TapMap>.error('missing');
    }).ignore();
    return future;
  }

  static Future<ui.Image> _decode(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  static Future<TapMap> _decodeMap(String asset) async {
    final image = await _decode(asset);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final map = TapMap(image.width, image.height, bytes!.buffer.asUint8List());
    image.dispose();
    return map;
  }
}

/// The result of [buildMask]: an RGBA picture the size of the tap map and the
/// box (in tap map pixels) around the selected parts, or null when none of
/// them can be seen.
class MaskResult {
  const MaskResult(this.pixels, this.width, this.height, this.box);

  final Uint8List pixels;
  final int width;
  final int height;

  /// [left, top, right, bottom], right and bottom exclusive.
  final List<int>? box;
}

/// Colours a tap map: [selected] parts (indexes in the model) get the colour
/// [hit], every other part gets [other] (both 0xAARRGGBB). Empty pixels stay
/// transparent. Runs on a background isolate so the screen does not stutter.
Future<MaskResult> buildMask(
  TapMap map,
  Set<int> selected,
  int hit,
  int other,
) {
  final src = map.pixels;
  final w = map.width;
  final h = map.height;
  final wanted = selected.toList();
  return Isolate.run(() => _mask(src, w, h, wanted, hit, other));
}

MaskResult _mask(Uint8List src, int w, int h, List<int> wanted, int hit, int other) {
  final sel = wanted.toSet();
  final px = Uint8List(w * h * 4);
  final hr = (hit >> 16) & 0xFF, hg = (hit >> 8) & 0xFF, hb = hit & 0xFF;
  final ha = (hit >> 24) & 0xFF;
  final or = (other >> 16) & 0xFF, og = (other >> 8) & 0xFF, ob = other & 0xFF;
  final oa = (other >> 24) & 0xFF;
  var minX = w, minY = h, maxX = -1, maxY = -1;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final o = (y * w + x) * 4;
      final id = src[o] + src[o + 1] * 256;
      if (id == 0) continue;
      if (sel.contains(id - 1)) {
        px[o] = hr;
        px[o + 1] = hg;
        px[o + 2] = hb;
        px[o + 3] = ha;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      } else {
        px[o] = or;
        px[o + 1] = og;
        px[o + 2] = ob;
        px[o + 3] = oa;
      }
    }
  }
  final box = maxX >= 0 ? [minX, minY, maxX + 1, maxY + 1] : null;
  return MaskResult(px, w, h, box);
}

/// Turns raw RGBA pixels into a picture that can be drawn.
Future<ui.Image> imageFromPixels(Uint8List pixels, int width, int height) {
  final done = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    done.complete,
  );
  return done.future;
}
