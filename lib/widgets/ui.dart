import 'package:flutter/material.dart';

import '../theme.dart';

/// A row (or column) of options where one is chosen.
class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.expand = false,
    this.vertical = false,
    this.height = 40,
    this.itemWidth,
  });

  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onChanged;

  /// Share the available width equally between the options.
  final bool expand;

  /// Options stacked on top of each other.
  final bool vertical;
  final double height;

  /// Fixed width of each option (used when [vertical]).
  final double? itemWidth;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (final entry in options.entries)
        Semantics(
          selected: entry.key == value,
          button: true,
          child: Material(
            color: entry.key == value ? AnatomoColors.text : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onChanged(entry.key),
              child: SizedBox(
                height: vertical ? height : null,
                width: itemWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: entry.key == value
                            ? AnatomoColors.bg
                            : AnatomoColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    final decoration = BoxDecoration(
      color: AnatomoColors.panel,
      border: Border.all(color: AnatomoColors.line),
      borderRadius: BorderRadius.circular(13),
    );
    if (vertical) {
      return Container(
        padding: const EdgeInsets.all(3),
        decoration: decoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(height: 2),
              buttons[i],
            ],
          ],
        ),
      );
    }
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: decoration,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in buttons) expand ? Expanded(child: b) : b,
        ],
      ),
    );
  }
}

/// A square button with an icon (tools on the side of the body).
class SquareButton extends StatelessWidget {
  const SquareButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 44,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  /// Dark button (for example on top of a picture).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AnatomoColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: filled ? BorderSide.none : BorderSide(color: AnatomoColors.line),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 21, color: AnatomoColors.text),
          ),
        ),
      ),
    );
  }
}

/// A round chip that can be on or off, with an optional colour dot.
class ToggleChip extends StatelessWidget {
  const ToggleChip({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
    this.dot,
    this.leading,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;
  final Color? dot;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      button: true,
      child: Material(
        color: on ? AnatomoColors.text : AnatomoColors.panel,
        shape: StadiumBorder(
          side: BorderSide(color: on ? AnatomoColors.text : AnatomoColors.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dot != null) ...[
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                ],
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: on ? AnatomoColors.bg : AnatomoColors.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small grey title above a group.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: AnatomoColors.muted,
        ),
      ),
    );
  }
}

/// A white (or dark) card with a thin border.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius = 18,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final inner = padding == null ? child : Padding(padding: padding!, child: child);
    return Material(
      color: color ?? AnatomoColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: color == null ? BorderSide(color: AnatomoColors.line) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? inner : InkWell(onTap: onTap, child: inner),
    );
  }
}

/// Big page title with an optional line under it (tabs).
class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 14, color: AnatomoColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// A coloured square with the first letter of a name.
class LetterTile extends StatelessWidget {
  const LetterTile({super.key, required this.text, required this.color, this.size = 36});

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = text.isEmpty ? '?' : text.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
          shadows: const [Shadow(color: Color(0x55000000), blurRadius: 2)],
        ),
      ),
    );
  }
}
