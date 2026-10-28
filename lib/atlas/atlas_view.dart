import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'atlas_controller.dart';
import 'atlas_images.dart';

/// The body drawn from the 2D pictures: pinch to zoom, drag to move, tap a
/// part to open it.
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
  TapMap? _tap;
  String? _maskFor;
  Rect? _selectionBox; // in tap map pixels
  int _maskToken = 0;
  bool _maskPending = false;

  int _appliedFocus = 0;
  int _appliedReset = 0;

  Size _stage = Size.zero;

  /// Where the picture sits on the stage (above what covers its bottom).
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
  void didUpdateWidget(AtlasView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
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
        AtlasImages.image(color).then((img) {
          if (mounted && _colorAsset == color) setState(() => _color = img);
        }).catchError((Object _) {});
      }
    }
    if (skin != _skinAsset) {
      _skinAsset = skin;
      if (skin == null) {
        _skin = null;
      } else {
        AtlasImages.image(skin).then((img) {
          if (mounted && _skinAsset == skin) setState(() => _skin = img);
        }).catchError((Object _) {});
      }
    }
    if (tap != _tapAsset) {
      _tapAsset = tap;
      _tap = null;
      if (tap != null) {
        AtlasImages.map(tap).then((map) {
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

  /// Fades everything but the selection, and finds where the selection is.
  void _updateMask() {
    final tap = _tap;
    final selected = _c.selected;
    final key = '${_tapAsset ?? ''}|${_c.focusRequest}|${selected.length}|'
        '${selected.isEmpty ? '' : selected.first}|${AnatomoColors.isLight}';
    if (key == _maskFor) {
      if (!_maskPending) _applyRequests();
      return;
    }
    if (selected.isEmpty || tap == null) {
      if (selected.isEmpty) {
        _maskFor = key;
        _mask = null;
        _selectionBox = null;
        _maskPending = false;
      }
      _applyRequests();
      return;
    }
    _maskFor = key;
    _maskPending = true;
    final token = ++_maskToken;
    final stage = AnatomoColors.stage.toARGB32() & 0x00FFFFFF;
    buildMask(tap, selected, 0x2EFFFFFF, 0xAA000000 | stage).then((result) async {
      if (!mounted || token != _maskToken) return;
      final box = result.box;
      _selectionBox = box == null
          ? null
          : Rect.fromLTRB(
              box[0].toDouble(),
              box[1].toDouble(),
              box[2].toDouble(),
              box[3].toDouble(),
            );
      _maskPending = false;
      if (box == null) widget.onHidden?.call();
      _applyRequests();
      final img = await imageFromPixels(result.pixels, result.width, result.height);
      if (!mounted || token != _maskToken) {
        img.dispose();
        return;
      }
      setState(() => _mask = img);
    }).catchError((Object _) {
      _maskPending = false;
    });
  }

  void _applyRequests() {
    if (_stage == Size.zero) return;
    if (_c.resetRequest != _appliedReset) {
      _appliedReset = _c.resetRequest;
      if (_c.selected.isEmpty) _animateTo(Matrix4.identity());
    }
    if (_c.focusRequest != _appliedFocus && _c.selected.isNotEmpty) {
      final tap = _tap;
      if (tap == null || _maskPending) return; // wait for the tap map
      _appliedFocus = _c.focusRequest;
      final box = _selectionBox;
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
