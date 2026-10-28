import 'package:flutter/material.dart';

class _Palette {
  const _Palette({
    required this.bg,
    required this.stage,
    required this.panel,
    required this.panel2,
    required this.picture,
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
    required this.goodTint,
    required this.badTint,
  });

  final Color bg, stage, panel, panel2, picture, line, text, body, muted;
  final Color accent, accentInk, tint, grip, good, bad, goodTint, badTint;

  static const dark = _Palette(
    bg: Color(0xFF0A1214),
    stage: Color(0xFF0A1214),
    panel: Color(0xFF121D20),
    panel2: Color(0xFF0F181A),
    picture: Color(0xFF13201F),
    line: Color(0xFF22302F),
    text: Color(0xFFE8F0EF),
    body: Color(0xFFC9D5D3),
    muted: Color(0xFF93A5A8),
    accent: Color(0xFF3CC9B8),
    accentInk: Color(0xFF062421),
    tint: Color(0xFF17383A),
    grip: Color(0xFF3A4A4C),
    good: Color(0xFF5CC48E),
    bad: Color(0xFFEE8A62),
    goodTint: Color(0xFF16352B),
    badTint: Color(0xFF3A231B),
  );

  static const light = _Palette(
    bg: Color(0xFFF3F6F5),
    stage: Color(0xFFF3F6F5),
    panel: Color(0xFFFFFFFF),
    panel2: Color(0xFFEEF2F1),
    picture: Color(0xFFE3EDEB),
    line: Color(0xFFE2E8E7),
    text: Color(0xFF0E1A1C),
    body: Color(0xFF2A3739),
    muted: Color(0xFF5B6B6E),
    accent: Color(0xFF0B7A70),
    accentInk: Color(0xFFFFFFFF),
    tint: Color(0xFFDDF0EC),
    grip: Color(0xFFD0DAD9),
    good: Color(0xFF08625A),
    bad: Color(0xFFB5422B),
    goodTint: Color(0xFFDDF0EC),
    badTint: Color(0xFFFBE6E0),
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

  /// Behind the body (2D pictures and the 3D view).
  static Color get stage => _p.stage;
  static Color get panel => _p.panel;
  static Color get panel2 => _p.panel2;

  /// Behind the small pictures of a part.
  static Color get picture => _p.picture;
  static Color get line => _p.line;
  static Color get text => _p.text;
  static Color get body => _p.body;
  static Color get muted => _p.muted;
  static Color get accent => _p.accent;
  static Color get accentInk => _p.accentInk;

  /// Soft teal background of a selected tile.
  static Color get tint => _p.tint;

  /// The small handle on top of a sheet.
  static Color get grip => _p.grip;
  static Color get good => _p.good;
  static Color get bad => _p.bad;
  static Color get goodTint => _p.goodTint;
  static Color get badTint => _p.badTint;

  /// These look the same in both modes.
  static const Color deepTeal = Color(0xFF0B6E6D);
  static const Color coral = Color(0xFFD9553A);
}

/// Colours of the body systems (dots and tiles).
const Map<String, int> kSystemColors = {
  'circulatory': 0xFFC8443A,
  'digestive': 0xFFC98A2B,
  'nervous': 0xFFD8A31F,
  'respiratory': 0xFF3D8FB8,
  'skeletal': 0xFFA89A80,
  'muscular': 0xFFC8574A,
  'urinary': 0xFF6F7FC4,
  'endocrine': 0xFFB0832A,
  'lymphatic': 0xFF5BA88C,
  'reproductive': 0xFFC46A9A,
  'sensory': 0xFF4FA3A0,
  'integumentary': 0xFFD9A27E,
};

Color systemColor(String id) => Color(kSystemColors[id] ?? 0xFF46BFB4);

/// Colours of the layer dots on the layer chips.
const Map<String, int> kLayerColors = {
  'organs': 0xFFB4505F,
  'bones': 0xFFCFC6B4,
  'muscles': 0xFFC8574A,
  'nerves': 0xFFD8A31F,
  'vessels': 0xFF3D6FC4,
  'skin': 0xFFE2B49A,
};

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
    dividerTheme: DividerThemeData(color: AnatomoColors.line, space: 1, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: AnatomoColors.bg,
      foregroundColor: AnatomoColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AnatomoColors.panel,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AnatomoColors.tint,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AnatomoColors.accent
              : AnatomoColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? AnatomoColors.accent
              : AnatomoColors.muted,
        ),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AnatomoColors.accent,
      inactiveTrackColor: AnatomoColors.line,
      thumbColor: AnatomoColors.accent,
      overlayColor: AnatomoColors.accent.withAlpha(36),
      trackHeight: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AnatomoColors.text,
      contentTextStyle: TextStyle(color: AnatomoColors.bg),
      behavior: SnackBarBehavior.floating,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AnatomoColors.accent
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AnatomoColors.accentInk
              : AnatomoColors.text,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: AnatomoColors.line)),
      ),
    ),
  );
}
