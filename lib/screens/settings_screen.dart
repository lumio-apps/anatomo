import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../languages.dart';
import '../settings.dart';
import '../theme.dart';
import '../update_service.dart';
import '../widgets/logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  bool _checking = false;
  String? _status;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_changed);
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    widget.settings.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _pickLanguage() async {
    final current = Localizations.localeOf(context).languageCode;
    final code = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AnatomoColors.panel,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final lang in kLanguages)
                ListTile(
                  title: Text(lang.nativeName),
                  subtitle: Text(
                    lang.englishName,
                    style: TextStyle(color: AnatomoColors.muted),
                  ),
                  trailing: lang.code == current
                      ? Icon(Icons.check_rounded, color: AnatomoColors.accent)
                      : null,
                  onTap: () => Navigator.of(context).pop(lang.code),
                ),
            ],
          ),
        ),
      ),
    );
    if (code != null) widget.settings.setLanguage(code);
  }

  Future<void> _checkForUpdates() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _checking = true;
      _status = null;
    });
    UpdateInfo? update;
    try {
      update = await UpdateChecker.check();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _status = t.updateFailed;
        _statusIsError = true;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _status = update == null ? t.upToDate : null;
      _statusIsError = false;
    });
    final found = update;
    if (found != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _UpdateDialog(info: found),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = languageFor(Localizations.localeOf(context).languageCode);
    final sex = widget.settings.sex;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _SectionTitle(t.general),
          _Card(
            children: [
              ListTile(
                leading: Icon(Icons.language_rounded, color: AnatomoColors.accent),
                title: Text(t.language),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.nativeName,
                      style: TextStyle(color: AnatomoColors.muted),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AnatomoColors.muted),
                  ],
                ),
                onTap: _pickLanguage,
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contrast_rounded, color: AnatomoColors.accent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(t.appearance,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(value: 'system', label: Text(t.themeAuto)),
                          ButtonSegment(value: 'light', label: Text(t.themeLight)),
                          ButtonSegment(value: 'dark', label: Text(t.themeDark)),
                        ],
                        selected: {widget.settings.theme},
                        onSelectionChanged: (s) =>
                            widget.settings.setTheme(s.first),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.accessibility_new_rounded,
                            color: AnatomoColors.accent),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(t.body, style: const TextStyle(fontSize: 16)),
                        ),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(value: 'male', label: Text(t.male)),
                            ButtonSegment(value: 'female', label: Text(t.female)),
                          ],
                          selected: {sex},
                          onSelectionChanged: (s) =>
                              widget.settings.setSex(s.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.femaleNote,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AnatomoColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _SectionTitle(t.updates),
          _Card(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AnatomoMark(size: 40),
                        const SizedBox(width: 12),
                        Text(
                          _version.isEmpty ? 'Anatomo' : t.versionLabel(_version),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _status!,
                        style: TextStyle(
                          fontSize: 14,
                          color: _statusIsError
                              ? AnatomoColors.bad
                              : AnatomoColors.good,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AnatomoColors.accent,
                          foregroundColor: AnatomoColors.accentInk,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _checking ? null : _checkForUpdates,
                        child: Text(_checking ? t.checking : t.checkForUpdates),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.updatesNote,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AnatomoColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _SectionTitle(t.about),
          _Card(
            children: [
              _InfoTile(
                title: t.sourceCode,
                child: SelectableText(
                  'github.com/$kGithubOwner/$kGithubRepo',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AnatomoColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              _InfoTile(title: t.models3d, text: t.modelsCredit),
              const Divider(height: 1),
              _InfoTile(title: t.privacy, text: t.privacyText),
              const Divider(height: 1),
              _InfoTile(title: t.disclaimerTitle, text: t.disclaimer),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AnatomoColors.muted,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AnatomoColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AnatomoColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, this.text, this.child});

  final String title;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AnatomoColors.muted,
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.info});

  final UpdateInfo info;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double? _progress;
  String? _error;

  Future<void> _install() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await UpdateChecker.downloadAndInstall(widget.info, (p) {
        if (mounted) setState(() => _progress = p);
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = t.installFailed('$e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final progress = _progress;
    return AlertDialog(
      backgroundColor: AnatomoColors.panel,
      title: Text(t.updateAvailable(widget.info.version)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.info.notes.isNotEmpty)
              Text(
                widget.info.notes,
                style: TextStyle(fontSize: 13.5, color: AnatomoColors.body),
              ),
            if (progress != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progress > 0 ? progress : null),
              const SizedBox(height: 8),
              Text(t.downloading((progress * 100).round())),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: AnatomoColors.bad)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: progress != null ? null : () => Navigator.of(context).pop(),
          child: Text(t.later),
        ),
        FilledButton(
          onPressed: progress != null ? null : _install,
          child: Text(t.downloadInstall),
        ),
      ],
    );
  }
}
