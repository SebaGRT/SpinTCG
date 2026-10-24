import 'dart:math';
import 'package:flutter/material.dart';

const _skin = [
  Color(0xfff1c8a5),
  Color(0xffe0ac85),
  Color(0xffc68b62),
  Color(0xff8d5a3b),
  Color(0xfff5d3b8),
];
const _hair = [
  Color(0xff2a1e17),
  Color(0xff5a3a22),
  Color(0xffa06a3a),
  Color(0xff1a1a1a),
  Color(0xffc9a16b),
];
const _shirt = [
  Color(0xfff2f4ee),
  Color(0xffdcf04a),
  Color(0xff1f6fb2),
  Color(0xffe4572e),
  Color(0xff2b2d42),
  Color(0xfff4a259),
  Color(0xff7b5ea7),
  Color(0xff3ba99c),
  Color(0xffc8102e),
  Color(0xffffffff),
];
const _silhouette = Color(0xffc9cfc9);

class PlayerFigure extends StatelessWidget {
  final int seed;
  final bool silhouette;
  const PlayerFigure({super.key, this.seed = 0, this.silhouette = false});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: FractionallySizedBox(
      heightFactor: 0.86,
      child: AspectRatio(
        aspectRatio: 100 / 120,
        child: CustomPaint(painter: _FigurePainter(seed, silhouette)),
      ),
    ),
  );
}

class _FigurePainter extends CustomPainter {
  final int seed;
  final bool silhouette;
  _FigurePainter(this.seed, this.silhouette);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 120);
    final skin = silhouette ? _silhouette : _skin[(seed * 3) % _skin.length];
    final hair = silhouette ? _silhouette : _hair[(seed * 7) % _hair.length];
    final shirt = silhouette ? _silhouette : _shirt[(seed * 5) % _shirt.length];
    Paint fill(Color c) => Paint()..color = c;

    canvas.save();
    canvas.translate(78, 52);
    canvas.rotate(-24 * pi / 180);
    canvas.translate(-78, -52);
    final frame = silhouette ? _silhouette : const Color(0xffdcf04a);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(78, 40), width: 26, height: 34),
      Paint()
        ..color = frame
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );
    if (!silhouette) {
      final strings = Paint()
        ..color = frame.withValues(alpha: 0.45)
        ..strokeWidth = 0.8;
      for (final (a, b) in [
        (const Offset(70, 32), const Offset(86, 32)),
        (const Offset(68, 40), const Offset(88, 40)),
        (const Offset(70, 48), const Offset(86, 48)),
        (const Offset(74, 26), const Offset(74, 54)),
        (const Offset(78, 24), const Offset(78, 56)),
        (const Offset(82, 26), const Offset(82, 54)),
      ]) {
        canvas.drawLine(a, b, strings);
      }
    }
    canvas.drawRRect(
      RRect.fromLTRBR(76, 57, 80, 79, const Radius.circular(2)),
      fill(silhouette ? _silhouette : const Color(0xff1b1b1b)),
    );
    canvas.restore();

    final torso = Path()
      ..moveTo(14, 120)
      ..cubicTo(14, 94, 29, 80, 50, 80)
      ..cubicTo(71, 80, 86, 94, 86, 120)
      ..close();
    canvas.drawPath(torso, fill(shirt));

    final collar = Path()
      ..moveTo(41, 80)
      ..lineTo(50, 91)
      ..lineTo(59, 80);
    canvas.drawPath(
      collar,
      Paint()
        ..color = silhouette
            ? _silhouette
            : Colors.black.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawRRect(
      RRect.fromLTRBR(43, 62, 57, 80, const Radius.circular(6)),
      fill(skin),
    );
    canvas.drawCircle(const Offset(50, 48), 17, fill(skin));

    final hairPath = Path()
      ..moveTo(33, 46)
      ..cubicTo(33, 34, 40, 27, 50, 27)
      ..cubicTo(60, 27, 67, 34, 67, 45)
      ..cubicTo(63, 39, 57, 37, 50, 37)
      ..cubicTo(43, 37, 38, 40, 33, 46)
      ..close();
    canvas.drawPath(hairPath, fill(hair));

    if (!silhouette) {
      canvas.drawRRect(
        RRect.fromLTRBR(33, 40, 67, 45, const Radius.circular(2.5)),
        fill(Colors.white.withValues(alpha: 0.9)),
      );
    }
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.seed != seed || old.silhouette != silhouette;
}
