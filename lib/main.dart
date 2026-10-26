import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'settings.dart';
import 'theme.dart';
import 'widgets/logo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // If something goes wrong, show the error text instead of a blank screen.
  ErrorWidget.builder = (FlutterErrorDetails details) => Material(
        color: AnatomoColors.bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              details.exceptionAsString(),
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      );

  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  runApp(const _Bootstrap());
}

/// Shows the logo straight away and reads the saved settings in the
/// background, so the app never waits on the phone's storage.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    AppSettings settings;
    try {
      settings = await AppSettings.load().timeout(const Duration(seconds: 5));
    } catch (_) {
      // The app still works without saving.
      settings = AppSettings.inMemory();
    }
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings != null) return AnatomoApp(settings: settings);
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: AnatomoColors.bg,
        child: Center(child: AnatomoMark(size: 96)),
      ),
    );
  }
}
