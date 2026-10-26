import 'package:flutter/material.dart';

/// Anatomo colours. The app has one dark look that matches the 3D viewer.
class AnatomoColors {
  AnatomoColors._();

  static const Color bg = Color(0xFF0A1215);
  static const Color stage = Color(0xFF0D171B);
  static const Color panel = Color(0xFF142227);
  static const Color panel2 = Color(0xFF0F1B1F);
  static const Color line = Color(0xFF26393F);
  static const Color text = Color(0xFFE9F1F0);
  static const Color body = Color(0xFFCFDADA);
  static const Color muted = Color(0xFF98ADAF);
  static const Color accent = Color(0xFF46BFB4);
  static const Color accentInk = Color(0xFF062523);
  static const Color deepTeal = Color(0xFF0B6E6D);
  static const Color coral = Color(0xFFE8674C);
  static const Color good = Color(0xFF5CC48E);
  static const Color bad = Color(0xFFEE8A62);
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: AnatomoColors.accent,
    onPrimary: AnatomoColors.accentInk,
    secondary: AnatomoColors.coral,
    surface: AnatomoColors.panel,
    onSurface: AnatomoColors.text,
    outline: AnatomoColors.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AnatomoColors.bg,
    dividerColor: AnatomoColors.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: AnatomoColors.bg,
      foregroundColor: AnatomoColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AnatomoColors.accent,
      inactiveTrackColor: AnatomoColors.line,
      thumbColor: AnatomoColors.accent,
      overlayColor: Color(0x2246BFB4),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AnatomoColors.panel,
      contentTextStyle: TextStyle(color: AnatomoColors.text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
