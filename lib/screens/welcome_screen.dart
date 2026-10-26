import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../languages.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/logo.dart';

/// First screen: choose a language.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late String _picked;

  @override
  void initState() {
    super.initState();
    final phone =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _picked = widget.settings.language ??
        (kLanguages.any((l) => l.code == phone) ? phone : 'en');
  }

  void _pick(String code) {
    setState(() => _picked = code);
    widget.settings.setLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AnatomoMark(size: 64),
              const SizedBox(height: 16),
              Text(
                t.welcomeTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.welcomeSubtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: AnatomoColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: kLanguages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 56,
                  ),
                  itemBuilder: (context, i) {
                    final lang = kLanguages[i];
                    return _LanguageTile(
                      language: lang,
                      selected: lang.code == _picked,
                      onTap: () => _pick(lang.code),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AnatomoColors.accent,
                    foregroundColor: AnatomoColors.accentInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    widget.settings.setLanguage(_picked);
                    widget.settings.finishOnboarding();
                  },
                  child: Text(t.continueButton),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  t.offlineNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AnatomoColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AnatomoColors.tint : AnatomoColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AnatomoColors.accent : AnatomoColors.line,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      language.englishName,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        color: AnatomoColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded,
                    color: AnatomoColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
