import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../pack/pack3d.dart';
import '../theme.dart';

/// Offers to download the 3D pack; true when it is ready afterwards.
Future<bool> askForPack(BuildContext context) async {
  final pack = Pack3D.instance;
  if (pack.ready) return true;
  await showDialog<void>(
    context: context,
    builder: (_) => PackDialog(pack: pack),
  );
  return pack.ready;
}

/// Asks to download the 3D pack and shows the download.
class PackDialog extends StatefulWidget {
  const PackDialog({super.key, required this.pack});

  final Pack3D pack;

  @override
  State<PackDialog> createState() => _PackDialogState();
}

class _PackDialogState extends State<PackDialog> {
  bool _closed = false;

  Pack3D get _pack => widget.pack;

  @override
  void initState() {
    super.initState();
    _pack.addListener(_changed);
  }

  @override
  void dispose() {
    _pack.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    if (_pack.ready) {
      _close();
    } else {
      setState(() {});
    }
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = _pack.state;
    final downloading = state == PackState.downloading;
    return AlertDialog(
      backgroundColor: AnatomoColors.panel,
      title: Text(t.pack3dTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.pack3dNote(kPackSizeMb)),
          if (downloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _pack.progress > 0 ? _pack.progress : null),
            const SizedBox(height: 8),
            Text(t.downloading((_pack.progress * 100).round())),
          ],
          if (state == PackState.failed) ...[
            const SizedBox(height: 12),
            Text(t.pack3dFailed, style: TextStyle(color: AnatomoColors.bad)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (downloading) _pack.cancel();
            _close();
          },
          child: Text(downloading ? t.cancel : t.later),
        ),
        if (!downloading)
          FilledButton(
            onPressed: _pack.download,
            child: Text(t.pack3dDownload),
          ),
      ],
    );
  }
}
