import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../body_manifest.dart';
import '../theme.dart';
import 'atlas_controller.dart';
import 'atlas_images.dart';

/// A picture of one part, cut from the 2D pictures: the part in colour, the
/// parts around it faded. [focus] zooms in on the part; otherwise the whole
/// body is shown so you can see where the part is.
class PartPicture extends StatefulWidget {
  const PartPicture({
    super.key,
    required this.manifest,
    required this.partKey,
    this.partId,
    this.focus = true,
    this.fade,
  });

  final BodyManifest manifest;
  final String partKey;

  /// Only this piece instead of the whole key.
  final String? partId;
  final bool focus;

  /// Colour laid over the other parts (defaults to the picture background).
  final Color? fade;

  @override
  State<PartPicture> createState() => _PartPictureState();
}

/// A part found in one of the pictures.
class _Found {
  _Found(this.color, this.mask, this.box);

  final ui.Image color;
  final ui.Image mask;

  /// The part's box, from 0 to 1 in both directions.
  final Rect box;
}

class _PartPictureState extends State<PartPicture> {
  static final Map<String, Future<_Found?>> _cache = {};
  static const int _keep = 8;

  _Found? _found;
  bool _missing = false;
  String? _loading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PartPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.partKey != widget.partKey ||
        oldWidget.partId != widget.partId ||
        oldWidget.manifest != widget.manifest) {
      _load();
    }
  }

  Color get _fade => widget.fade ?? AnatomoColors.picture;

  String get _cacheKey =>
      '${widget.manifest.sex}|${widget.partKey}|${widget.partId ?? ''}|'
      '${_fade.toARGB32()}';

  void _load() {
    final key = _cacheKey;
    _loading = key;
    final hit = _cache.remove(key);
    final future = hit ?? _find(widget.manifest, widget.partKey, widget.partId, _fade);
    _cache[key] = future;
    while (_cache.length > _keep) {
      _cache.remove(_cache.keys.first);
    }
    future.then((found) {
      if (!mounted || _loading != key) return;
      setState(() {
        _found = found;
        _missing = found == null;
      });
    }).catchError((Object _) {
      _cache.remove(key);
      if (mounted && _loading == key) setState(() => _missing = true);
    });
  }

  static Future<_Found?> _find(
    BodyManifest m,
    String key,
    String? partId,
    Color fade,
  ) async {
    final Set<int> indexes;
    if (partId != null) {
      indexes = {
        for (final p in m.parts)
          if (p.id == partId) p.index,
      };
    } else {
      indexes = {for (final p in m.partsOf(key)) p.index};
    }
    if (indexes.isEmpty) return null;
    final layer = m.keyLayers[key] ?? 'organs';
    final mix = layer == 'skin' ? 's' : (kAtlasLetters[layer] ?? 'o');
    final other = 0xC8000000 | (fade.toARGB32() & 0x00FFFFFF);
    for (final view in const ['front', 'back', 'side']) {
      final base = 'assets/atlas/${m.sex}/$view/$mix';
      final map = await AtlasImages.map('$base.ids.png');
      final mask = await buildMask(map, indexes, 0x00000000, other);
      final box = mask.box;
      if (box == null) continue;
      final color = await AtlasImages.image('$base.webp');
      final maskImage = await imageFromPixels(mask.pixels, mask.width, mask.height);
      return _Found(
        color,
        maskImage,
        Rect.fromLTRB(
          box[0] / mask.width,
          box[1] / mask.height,
          box[2] / mask.width,
          box[3] / mask.height,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final found = _found;
    if (found == null) {
      return Center(
        child: _missing
            ? Icon(Icons.image_not_supported_outlined, color: AnatomoColors.muted)
            : SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AnatomoColors.accent,
                ),
              ),
      );
    }
    return CustomPaint(
      painter: _PicturePainter(found, widget.focus),
      child: const SizedBox.expand(),
    );
  }
}

class _PicturePainter extends CustomPainter {
  _PicturePainter(this.found, this.focus);

  final _Found found;
  final bool focus;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final color = found.color;
    final cw = color.width.toDouble();
    final ch = color.height.toDouble();
    Rect src;
    if (focus) {
      final b = found.box;
      final box = Rect.fromLTRB(b.left * cw, b.top * ch, b.right * cw, b.bottom * ch);
      // Some room around the part, a little more for small parts.
      final pad = math.max(box.longestSide * 0.45, ch * 0.05);
      var r = box.inflate(pad);
      // Same shape as the widget, so the picture fills it.
      final want = size.width / size.height;
      if (r.width / r.height < want) {
        final w = r.height * want;
        r = Rect.fromCenter(center: r.center, width: w, height: r.height);
      } else {
        final h = r.width / want;
        r = Rect.fromCenter(center: r.center, width: r.width, height: h);
      }
      // Keep it inside the picture where possible.
      var dx = 0.0, dy = 0.0;
      if (r.left < 0) dx = -r.left;
      if (r.right > cw) dx = cw - r.right;
      if (r.top < 0) dy = -r.top;
      if (r.bottom > ch) dy = ch - r.bottom;
      src = r.shift(Offset(dx, dy)).intersect(Rect.fromLTWH(0, 0, cw, ch));
    } else {
      src = Rect.fromLTWH(0, 0, cw, ch);
    }
    if (src.isEmpty) return;
    final s = math.min(size.width / src.width, size.height / src.height);
    final w = src.width * s;
    final h = src.height * s;
    final dst = Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h);
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(color, src, dst, paint);
    final mask = found.mask;
    final mx = mask.width / cw;
    final my = mask.height / ch;
    final msrc = Rect.fromLTRB(src.left * mx, src.top * my, src.right * mx, src.bottom * my);
    canvas.drawImageRect(mask, msrc, dst, Paint()..filterQuality = FilterQuality.low);
  }

  @override
  bool shouldRepaint(_PicturePainter oldDelegate) =>
      oldDelegate.found != found || oldDelegate.focus != focus;
}
