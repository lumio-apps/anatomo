import 'package:flutter/material.dart';

import '../content.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';

/// The details of a body part: what it does, what is good for it and what
/// harms it. Shown over the bottom of the 3D view.
class PartSheet extends StatelessWidget {
  const PartSheet({
    super.key,
    required this.title,
    required this.systemName,
    required this.color,
    required this.info,
    required this.partName,
    required this.tab,
    required this.onTab,
    required this.onClose,
    required this.favorite,
    required this.onFavorite,
    required this.onCopy,
  });

  final String title;
  final String systemName;
  final Color color;
  final PartContent? info;

  /// The exact piece that was tapped, when only one piece is selected.
  final String? partName;
  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onClose;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final labels = [t.tabAbout, t.tabGood, t.tabBad];
    return Container(
      decoration: BoxDecoration(
        color: AnatomoColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: AnatomoColors.line)),
        boxShadow: [
          BoxShadow(
            color: Color(AnatomoColors.isLight ? 0x22000000 : 0x66000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AnatomoColors.grip,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        systemName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AnatomoColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: favorite ? t.removeFavorite : t.addFavorite,
                  onPressed: onFavorite,
                  icon: Icon(
                    favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: favorite ? AnatomoColors.coral : AnatomoColors.muted,
                  ),
                ),
                IconButton(
                  tooltip: t.copyText,
                  onPressed: onCopy,
                  icon: Icon(Icons.copy_rounded, size: 20, color: AnatomoColors.muted),
                ),
                IconButton(
                  tooltip: t.showWholeBody,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: AnatomoColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AnatomoColors.panel2,
              border: Border.all(color: AnatomoColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: _TabButton(
                      label: labels[i],
                      selected: tab == i,
                      onTap: () => onTab(i),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: _body(t),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              4,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                t.notMedical,
                style: TextStyle(fontSize: 12, color: AnatomoColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations t) {
    final info = this.info;
    if (tab == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (partName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AnatomoColors.panel2,
                border: Border.all(color: AnatomoColors.line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.partLabel(partName!),
                style: TextStyle(fontSize: 13, color: AnatomoColors.body),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (info != null)
            Text(
              info.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: AnatomoColors.body,
              ),
            ),
          if (info != null && info.facts.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                final w = (c.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in info.facts)
                      Container(
                        width: w,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AnatomoColors.panel2,
                          border: Border.all(color: AnatomoColors.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f[0],
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AnatomoColors.muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              f[1],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      );
    }
    final good = tab == 1;
    final items = info == null ? const <String>[] : (good ? info.good : info.bad);
    return Column(
      children: [
        for (final item in items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AnatomoColors.panel2,
              border: Border.all(color: AnatomoColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    good ? Icons.check_rounded : Icons.error_outline_rounded,
                    size: 19,
                    color: good ? AnatomoColors.good : AnatomoColors.bad,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: AnatomoColors.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AnatomoColors.text : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: selected ? AnatomoColors.bg : AnatomoColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
