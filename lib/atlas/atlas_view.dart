import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'atlas_controller.dart';

/// A tap map: every pixel holds the number of the part drawn there
/// (red + 256 * green; 0 = nothing).
class _TapMap {
  _TapMap(this.width, this.height, this.pixels);

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

/// Decoded pictures, shared by all screens. Only a few are kept.
class _Store {
  static final Map<String, Future<ui.Image>> _images = {};
  static final Map<String, Future<_TapMap>> _maps = {};
  static const int _keep = 10;

  static Future<ui.Image> image(String asset) {
    final hit = _images.remove(asset);
    final future = hit ?? _decode(asset);
    _images[asset] = future; // most recent last
    while (_images.length > _keep) {
      _images.remove(_images.keys.first);
    }
    return future;
  }

  static Future<_TapMap> map(String asset) {
    final hit = _maps.remove(asset);
    final future = hit ?? _decodeMap(asset);
    _maps[asset] = future;
    while (_maps.length > _keep) {
      _maps.remove(_maps.keys.first);
    }
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

  static Future<_TapMap> _decodeMap(String asset) async {
    final image = await _decode(asset);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final map = _TapMap(image.width, image.height, bytes!.buffer.asUint8List());
    image.dispose();
    return map;
  }
}

/// The body drawn from the 2D pictures: pinch or scroll to zoom, drag to move,
/// tap a part to open it.
class AtlasView extends StatefulWidget {
  const AtlasView({super.key, required this.controller, this.onHidden});

  final AtlasController controller;

  /// The selected part cannot be seen from this side with these layers.
  final VoidCallback? onHidden;

  @override
  State<AtlasView> createState() => _AtlasViewState();
}

class _AtlasViewState extends State<AtlasView>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _anim;
  Matrix4Tween? _tween;

  String? _colorAsset, _skinAsset, _tapAsset;
  ui.Image? _color, _skin, _mask;
  _TapMap? _tap;
  String? _maskFor;
  Rect? _selectionBox; // in tap map pixels
  int _maskToken = 0;

  int _appliedFocus = 0;
  int _appliedReset = 0;

  Size _stage = Size.zero;

  /// Where the picture sits on the stage (above the details sheet).
  Rect get _body => _bodyRect(_stage, _c.inset);

  Rect _bodyRect(Size size, double inset) {
    if (size.isEmpty) return Rect.zero;
    final picture = _c.manifest?.pictureSizes[_c.view] ?? const [800, 2000];
    final availH = size.height * (1 - inset);
    final pad = math.min(24.0, size.shortestSide * 0.05);
    final fit = math.min(
      (size.width - pad * 2) / picture[0],
      (availH - pad * 2) / picture[1],
    );
    final w = math.max(0.0, picture[0] * fit);
    final h = math.max(0.0, picture[1] * fit);
    return Rect.fromLTWH((size.width - w) / 2, (availH - h) / 2, w, h);
  }

  AtlasController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() {
        final tween = _tween;
        if (tween != null) {
          _transform.value = tween.transform(Curves.easeOutCubic.transform(_anim.value));
        }
      });
    _appliedFocus = _c.focusRequest;
    _appliedReset = _c.resetRequest;
    _c.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(AtlasView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    _c.removeListener(_sync);
    _anim.dispose();
    _transform.dispose();
    super.dispose();
  }

  String _base() => 'assets/atlas/${_c.sex}/${_c.view}';

  void _sync() {
    if (!mounted) return;
    final manifest = _c.manifest;
    if (manifest == null) return;
    final mix = _c.mix;
    final base = _base();
    final color = mix.isEmpty ? null : '$base/$mix.webp';
    final skin = _c.skinOn ? '$base/s.webp' : null;
    final tap = mix.isNotEmpty
        ? '$base/$mix.ids.png'
        : (_c.skinOn ? '$base/s.ids.png' : null);

    if (color != _colorAsset) {
      _colorAsset = color;
      if (color == null) {
        _color = null;
      } else {
        _Store.image(color).then((img) {
          if (mounted && _colorAsset == color) setState(() => _color = img);
        }).catchError((Object _) {});
      }
    }
    if (skin != _skinAsset) {
      _skinAsset = skin;
      if (skin == null) {
        _skin = null;
      } else {
        _Store.image(skin).then((img) {
          if (mounted && _skinAsset == skin) setState(() => _skin = img);
        }).catchError((Object _) {});
      }
    }
    if (tap != _tapAsset) {
      _tapAsset = tap;
      _tap = null;
      if (tap != null) {
        _Store.map(tap).then((map) {
          if (!mounted || _tapAsset != tap) return;
          _tap = map;
          _updateMask();
        }).catchError((Object _) {});
      }
    }

    if (_c.pendingZoom != 1) {
      final f = _c.pendingZoom;
      _c.pendingZoom = 1;
      _zoomBy(f);
    }
    _updateMask();
    if (mounted) setState(() {});
  }

  /// Darkens everything but the selection, and finds where the selection is.
  void _updateMask() {
    final tap = _tap;
    final selected = _c.selected;
    final key = '${_tapAsset ?? ''}|${_c.focusRequest}|${selected.length}|'
        '${selected.isEmpty ? '' : selected.first}|${AnatomoColors.isLight}';
    if (key == _maskFor) {
      _applyRequests();
      return;
    }
    if (selected.isEmpty || tap == null) {
      if (selected.isEmpty) {
        _maskFor = key;
        _mask = null;
        _selectionBox = null;
      }
      _applyRequests();
      return;
    }
    _maskFor = key;
    final token = ++_maskToken;
    final light = AnatomoColors.isLight;
    // stage colour, see theme.dart
    final dr = light ? 0xE9 : 0x0D, dg = light ? 0xF0 : 0x17, db = light ? 0xF1 : 0x1B;
    final px = Uint8List(tap.width * tap.height * 4);
    var minX = tap.width, minY = tap.height, maxX = -1, maxY = -1;
    final src = tap.pixels;
    for (var y = 0; y < tap.height; y++) {
      for (var x = 0; x < tap.width; x++) {
        final o = (y * tap.width + x) * 4;
        final id = src[o] + src[o + 1] * 256;
        if (id == 0) continue;
        if (selected.contains(id - 1)) {
          px[o] = 255;
          px[o + 1] = 255;
          px[o + 2] = 255;
          px[o + 3] = 46;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        } else {
          px[o] = dr;
          px[o + 1] = dg;
          px[o + 2] = db;
          px[o + 3] = 170;
        }
      }
    }
    final found = maxX >= 0;
    _selectionBox = found
        ? Rect.fromLTRB(minX.toDouble(), minY.toDouble(), maxX + 1.0, maxY + 1.0)
        : null;
    if (!found) widget.onHidden?.call();
    ui.decodeImageFromPixels(px, tap.width, tap.height, ui.PixelFormat.rgba8888,
        (img) {
      if (!mounted || token != _maskToken) return;
      setState(() => _mask = img);
    });
    _applyRequests();
  }

  void _applyRequests() {
    if (_stage == Size.zero) return;
    if (_c.resetRequest != _appliedReset) {
      _appliedReset = _c.resetRequest;
      if (_c.selected.isEmpty) _animateTo(Matrix4.identity());
    }
    if (_c.focusRequest != _appliedFocus && _c.selected.isNotEmpty) {
      final box = _selectionBox;
      final tap = _tap;
      if (tap == null) return; // wait for the tap map
      _appliedFocus = _c.focusRequest;
      if (box == null) {
        _animateTo(Matrix4.identity());
        return;
      }
      final body = _body;
      final r = Rect.fromLTRB(
        body.left + box.left / tap.width * body.width,
        body.top + box.top / tap.height * body.height,
        body.left + box.right / tap.width * body.width,
        body.top + box.bottom / tap.height * body.height,
      );
      final avail = Rect.fromLTWH(0, 0, _stage.width, _stage.height * (1 - _c.inset));
      final s = math.min(
        avail.width * 0.72 / math.max(r.width, 1),
        avail.height * 0.72 / math.max(r.height, 1),
      ).clamp(1.0, 4.0).toDouble();
      final tx = avail.center.dx - s * r.center.dx;
      final ty = avail.center.dy - s * r.center.dy;
      _animateTo(_matrix(s, tx, ty));
    }
  }

  static Matrix4 _matrix(double s, double tx, double ty) => Matrix4.identity()
    ..setEntry(0, 0, s)
    ..setEntry(1, 1, s)
    ..setEntry(0, 3, tx)
    ..setEntry(1, 3, ty);

  void _animateTo(Matrix4 target) {
    _tween = Matrix4Tween(begin: _transform.value.clone(), end: target);
    _anim
      ..reset()
      ..forward();
  }

  void _zoomBy(double factor) {
    if (_stage == Size.zero) return;
    final m = _transform.value;
    final scale = m.getMaxScaleOnAxis();
    final t = m.getTranslation();
    final next = (scale * factor).clamp(1.0, 8.0).toDouble();
    final f = next / scale;
    final c = Offset(_stage.width / 2, _stage.height * (1 - _c.inset) / 2);
    final tx = c.dx + f * (t.x - c.dx);
    final ty = c.dy + f * (t.y - c.dy);
    _animateTo(_matrix(next, tx, ty));
  }

  void _onTap(TapUpDetails d) {
    final tap = _tap;
    final body = _body;
    if (tap == null || body.isEmpty) return;
    final p = d.localPosition;
    if (!body.contains(p)) {
      _c.tapEmpty();
      return;
    }
    final x = ((p.dx - body.left) / body.width * tap.width).floor();
    final y = ((p.dy - body.top) / body.height * tap.height).floor();
    final scale = _transform.value.getMaxScaleOnAxis();
    // about 10 screen pixels around the finger
    final radius = math.max(1, (10 / scale / body.width * tap.width).round());
    final id = tap.pick(x, y, radius);
    if (id == 0) {
      _c.tapEmpty();
    } else {
      _c.tapIndex(id - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AnatomoColors.stage,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final body = _bodyRect(size, _c.inset);
          if (_stage != size) {
            _stage = size;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _applyRequests();
            });
          }
          final onlySkin = _c.mix.isEmpty;
          final selected = _c.selected.isNotEmpty;
          return InteractiveViewer(
            transformationController: _transform,
            minScale: 1,
            maxScale: 8,
            boundaryMargin: const EdgeInsets.all(2000),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: _onTap,
                child: Stack(
                  children: [
                    if (_color != null)
                      Positioned.fromRect(
                        rect: body,
                        child: RawImage(
                          image: _color,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    if (_mask != null && selected)
                      Positioned.fromRect(
                        rect: body,
                        child: RawImage(
                          image: _mask,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                    if (_skin != null)
                      Positioned.fromRect(
                        rect: body,
                        child: Opacity(
                          opacity: onlySkin ? 1 : (selected ? 0.1 : 0.28),
                          child: RawImage(
                            image: _skin,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    if (_color == null && _skin == null && _colorAsset != null)
                      Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AnatomoColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
