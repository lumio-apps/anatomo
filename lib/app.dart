import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/explore_screen.dart';
import 'screens/welcome_screen.dart';
import 'settings.dart';
import 'theme.dart';

class AnatomoApp extends StatelessWidget {
  const AnatomoApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final code = settings.language;
        return MaterialApp(
          title: 'Anatomo',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: code == null ? null : Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: settings.onboarded
              ? ExploreScreen(settings: settings)
              : WelcomeScreen(settings: settings),
        );
      },
    );
  }
}
