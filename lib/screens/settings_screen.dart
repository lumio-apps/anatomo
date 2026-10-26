import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../languages.dart';
import '../pack/pack3d.dart';
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
    final noteStyle = TextStyle(fontSize: 12.5, height: 1.4, color: AnatomoColors.muted);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // On wide windows the settings stay a readable column, like the
          // settings pages of Windows, instead of stretching across.
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
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
                  _SettingRow(
                    icon: Icons.language_rounded,
                    title: t.language,
                    onTap: _pickLanguage,
                    control: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lang.nativeName, style: TextStyle(color: AnatomoColors.muted)),
                        Icon(Icons.chevron_right_rounded, color: AnatomoColors.muted),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.contrast_rounded,
                    title: t.appearance,
                    control: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: 'system', label: Text(t.themeAuto)),
                        ButtonSegment(value: 'light', label: Text(t.themeLight)),
                        ButtonSegment(value: 'dark', label: Text(t.themeDark)),
                      ],
                      selected: {widget.settings.theme},
                      onSelectionChanged: (s) => widget.settings.setTheme(s.first),
                    ),
                  ),
                  if (Pack3D.supported) ...[
                    const Divider(height: 1),
                    _SettingRow(
                      icon: Icons.speed_rounded,
                      title: t.quality,
                      note: t.qualityNote,
                      control: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(value: 'auto', label: Text(t.qualityAuto)),
                          ButtonSegment(value: 'low', label: Text(t.qualityLow)),
                          ButtonSegment(value: 'medium', label: Text(t.qualityMedium)),
                          ButtonSegment(value: 'high', label: Text(t.qualityHigh)),
                        ],
                        selected: {widget.settings.quality},
                        onSelectionChanged: (s) => widget.settings.setQuality(s.first),
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.accessibility_new_rounded,
                    title: t.body,
                    note: t.femaleNote,
                    control: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: 'male', label: Text(t.male)),
                        ButtonSegment(value: 'female', label: Text(t.female)),
                      ],
                      selected: {sex},
                      onSelectionChanged: (s) => widget.settings.setSex(s.first),
                    ),
                  ),
                ],
              ),
              if (Pack3D.supported) ...[
                _SectionTitle(t.pack3dTitle),
                _Card(children: [_PackTile(pack: Pack3D.instance)]),
              ],
              _SectionTitle(t.updates),
              _Card(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final wide = c.maxWidth >= 520;
                        final info = Row(
                          children: [
                            const AnatomoMark(size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _version.isEmpty ? 'Anatomo' : t.versionLabel(_version),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (_status != null)
                                    Text(
                                      _status!,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: _statusIsError
                                            ? AnatomoColors.bad
                                            : AnatomoColors.good,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                        final button = SizedBox(
                          width: wide ? null : double.infinity,
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AnatomoColors.accent,
                              foregroundColor: AnatomoColors.accentInk,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _checking ? null : _checkForUpdates,
                            child: Text(_checking ? t.checking : t.checkForUpdates),
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (wide)
                              Row(
                                children: [
                                  Expanded(child: info),
                                  const SizedBox(width: 16),
                                  button,
                                ],
                              )
                            else ...[
                              info,
                              const SizedBox(height: 12),
                              button,
                            ],
                            const SizedBox(height: 10),
                            Text(t.updatesNote, style: noteStyle),
                          ],
                        );
                      },
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
        ),
      ),
    );
  }
}

/// One setting: icon, title and note on the left, its control on the right
/// (or under the title when there is not enough room, as on phones).
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.control,
    this.note,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? note;
  final Widget control;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final noteText = note == null
        ? null
        : Text(
            note!,
            style: TextStyle(fontSize: 12.5, height: 1.4, color: AnatomoColors.muted),
          );
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: LayoutBuilder(
          builder: (context, c) {
            final side = c.maxWidth >= 560 || onTap != null;
            final head = Row(
              children: [
                Icon(icon, color: AnatomoColors.accent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16)),
                      if (side && noteText != null) ...[
                        const SizedBox(height: 2),
                        noteText,
                      ],
                    ],
                  ),
                ),
                if (side) ...[
                  const SizedBox(width: 16),
                  control,
                ],
              ],
            );
            if (side) return head;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                head,
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: control),
                if (noteText != null) ...[
                  const SizedBox(height: 8),
                  noteText,
                ],
              ],
            );
          },
        ),
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

class _PackTile extends StatelessWidget {
  const _PackTile({required this.pack});

  final Pack3D pack;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: pack,
      builder: (context, _) {
        final state = pack.state;
        final buttonStyle = FilledButton.styleFrom(
          backgroundColor: AnatomoColors.accent,
          foregroundColor: AnatomoColors.accentInk,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
        Widget action;
        switch (state) {
          case PackState.checking:
            action = const SizedBox.shrink();
          case PackState.ready:
            action = Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                onPressed: pack.remove,
                child: Text(t.pack3dRemove),
              ),
            );
          case PackState.downloading:
            action = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: pack.progress > 0 ? pack.progress : null),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(t.downloading((pack.progress * 100).round()))),
                    TextButton(onPressed: pack.cancel, child: Text(t.cancel)),
                  ],
                ),
              ],
            );
          case PackState.missing:
          case PackState.failed:
            action = Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  style: buttonStyle,
                  onPressed: pack.download,
                  child: Text(t.pack3dDownload),
                ),
              ),
            );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.view_in_ar_rounded, color: AnatomoColors.accent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      state == PackState.ready ? t.pack3dReady : t.pack3dNote(kPackSizeMb),
                      style: TextStyle(fontSize: 14, height: 1.4, color: AnatomoColors.body),
                    ),
                  ),
                ],
              ),
              if (state == PackState.failed) ...[
                const SizedBox(height: 10),
                Text(t.pack3dFailed, style: TextStyle(color: AnatomoColors.bad, fontSize: 13.5)),
              ],
              const SizedBox(height: 12),
              action,
            ],
          ),
        );
      },
    );
  }
}
