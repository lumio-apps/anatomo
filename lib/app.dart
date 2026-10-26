import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'screens/explore_screen.dart';
import 'screens/welcome_screen.dart';
import 'settings.dart';
import 'theme.dart';

class AnatomoApp extends StatefulWidget {
  const AnatomoApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<AnatomoApp> createState() => _AnatomoAppState();
}

class _AnatomoAppState extends State<AnatomoApp> with WidgetsBindingObserver {
  Brightness? _applied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The phone switched between dark and light.
  @override
  void didChangePlatformBrightness() {
    if (widget.settings.theme == 'system' && mounted) setState(() {});
  }

  Brightness _brightness() {
    switch (widget.settings.theme) {
      case 'light':
        return Brightness.light;
      case 'dark':
        return Brightness.dark;
      default:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  /// The colours are read when a widget is built, so when the mode changes
  /// every widget is built once more. Nothing is recreated: the 3D view and
  /// the open screens keep their state.
  void _rebuildEverything() {
    if (!mounted) return;
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final settings = widget.settings;
        final brightness = _brightness();
        final theme = buildTheme(brightness);
        if (_applied != null && _applied != brightness) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildEverything());
        }
        _applied = brightness;
        final code = settings.language;
        final light = brightness == Brightness.light;
        return MaterialApp(
          title: 'Anatomo',
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: code == null ? null : Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: light ? Brightness.dark : Brightness.light,
              statusBarBrightness: light ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: AnatomoColors.bg,
              systemNavigationBarIconBrightness:
                  light ? Brightness.dark : Brightness.light,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: settings.onboarded
              ? ExploreScreen(settings: settings)
              : WelcomeScreen(settings: settings),
        );
      },
    );
  }
}
