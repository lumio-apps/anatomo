import 'package:flutter/material.dart';

import '../theme.dart';

/// The Anatomo mark: a lens that shows a person with a heart.
class AnatomoMark extends StatelessWidget {
  const AnatomoMark({super.key, this.size = 36, this.tile = true});

  final double size;

  /// Draw the rounded teal tile behind the mark.
  final bool tile;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(
      size: Size.square(size * (tile ? 0.78 : 1)),
      painter: const _MarkPainter(),
    );
    if (!tile) return mark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AnatomoColors.deepTeal,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      alignment: Alignment.center,
      child: mark,
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.save();
    canvas.scale(s);

    final white = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: const Offset(44, 44), radius: 23.5)),
    );
    canvas.drawCircle(const Offset(44, 36), 8, white);
    final shoulders = Path()
      ..moveTo(26, 68)
      ..quadraticBezierTo(27, 49, 44, 48)
      ..quadraticBezierTo(61, 49, 62, 68)
      ..close();
    canvas.drawPath(shoulders, white);
    final heart = Path()
      ..moveTo(48, 62)
      ..cubicTo(43.5, 58.6, 41.5, 56, 41.5, 53.6)
      ..cubicTo(41.5, 51.4, 43.3, 50, 45, 50)
      ..cubicTo(46.3, 50, 47.4, 50.7, 48, 51.8)
      ..cubicTo(48.6, 50.7, 49.7, 50, 51, 50)
      ..cubicTo(52.7, 50, 54.5, 51.4, 54.5, 53.6)
      ..cubicTo(54.5, 56, 52.5, 58.6, 48, 62)
      ..close();
    canvas.drawPath(heart, Paint()..color = AnatomoColors.coral);
    canvas.restore();

    canvas.drawCircle(
      const Offset(44, 44),
      27,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.drawLine(
      const Offset(64, 64),
      const Offset(79, 79),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "anatomo" with the last letter in coral.
class AnatomoWordmark extends StatelessWidget {
  const AnatomoWordmark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: AnatomoColors.text,
    );
    return Text.rich(
      TextSpan(
        style: style,
        children: const [
          TextSpan(text: 'anatom'),
          TextSpan(text: 'o', style: TextStyle(color: AnatomoColors.coral)),
        ],
      ),
    );
  }
}
