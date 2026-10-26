import 'package:flutter/material.dart';

class _Palette {
  const _Palette({
    required this.bg,
    required this.stage,
    required this.panel,
    required this.panel2,
    required this.line,
    required this.text,
    required this.body,
    required this.muted,
    required this.accent,
    required this.accentInk,
    required this.tint,
    required this.grip,
    required this.good,
    required this.bad,
  });

  final Color bg, stage, panel, panel2, line, text, body, muted;
  final Color accent, accentInk, tint, grip, good, bad;

  static const dark = _Palette(
    bg: Color(0xFF0A1215),
    stage: Color(0xFF0D171B),
    panel: Color(0xFF142227),
    panel2: Color(0xFF0F1B1F),
    line: Color(0xFF26393F),
    text: Color(0xFFE9F1F0),
    body: Color(0xFFCFDADA),
    muted: Color(0xFF98ADAF),
    accent: Color(0xFF46BFB4),
    accentInk: Color(0xFF062523),
    tint: Color(0xFF12302F),
    grip: Color(0xFF3A5056),
    good: Color(0xFF5CC48E),
    bad: Color(0xFFEE8A62),
  );

  static const light = _Palette(
    bg: Color(0xFFF3F7F7),
    stage: Color(0xFFE9F0F1),
    panel: Color(0xFFFFFFFF),
    panel2: Color(0xFFEFF5F5),
    line: Color(0xFFD0DEDF),
    text: Color(0xFF10201F),
    body: Color(0xFF30464A),
    muted: Color(0xFF5B7377),
    accent: Color(0xFF0B7F7A),
    accentInk: Color(0xFFFFFFFF),
    tint: Color(0xFFD9EEEC),
    grip: Color(0xFFB5C8CA),
    good: Color(0xFF1B8F5A),
    bad: Color(0xFFC4532B),
  );
}

/// Anatomo colours. They follow the current mode (dark or light), which is set
/// with [AnatomoColors.use] before the screens are built.
class AnatomoColors {
  AnatomoColors._();

  static _Palette _p = _Palette.dark;

  static bool get isLight => identical(_p, _Palette.light);

  static void use(Brightness brightness) {
    _p = brightness == Brightness.light ? _Palette.light : _Palette.dark;
  }

  static Color get bg => _p.bg;
  static Color get stage => _p.stage;
  static Color get panel => _p.panel;
  static Color get panel2 => _p.panel2;
  static Color get line => _p.line;
  static Color get text => _p.text;
  static Color get body => _p.body;
  static Color get muted => _p.muted;
  static Color get accent => _p.accent;
  static Color get accentInk => _p.accentInk;

  /// Soft teal background of a selected tile.
  static Color get tint => _p.tint;

  /// The small handle on top of the details sheet.
  static Color get grip => _p.grip;
  static Color get good => _p.good;
  static Color get bad => _p.bad;

  /// These two look the same in both modes.
  static const Color deepTeal = Color(0xFF0B6E6D);
  static const Color coral = Color(0xFFE8674C);
}

ThemeData buildTheme(Brightness brightness) {
  AnatomoColors.use(brightness);
  final scheme = (brightness == Brightness.light
          ? const ColorScheme.light()
          : const ColorScheme.dark())
      .copyWith(
    primary: AnatomoColors.accent,
    onPrimary: AnatomoColors.accentInk,
    secondary: AnatomoColors.coral,
    surface: AnatomoColors.panel,
    onSurface: AnatomoColors.text,
    outline: AnatomoColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: AnatomoColors.bg,
    dividerColor: AnatomoColors.line,
    appBarTheme: AppBarTheme(
      backgroundColor: AnatomoColors.bg,
      foregroundColor: AnatomoColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AnatomoColors.accent,
      inactiveTrackColor: AnatomoColors.line,
      thumbColor: AnatomoColors.accent,
      overlayColor: AnatomoColors.accent.withAlpha(36),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AnatomoColors.panel,
      contentTextStyle: TextStyle(color: AnatomoColors.text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
