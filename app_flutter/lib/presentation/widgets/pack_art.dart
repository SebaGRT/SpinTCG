import 'package:flutter/material.dart';
import '../theme.dart';

class PackArt extends StatelessWidget {
  final bool opened;
  final double width;
  const PackArt({super.key, this.opened = false, this.width = 200});

  @override
  Widget build(BuildContext context) {
    final art = SizedBox(
      width: width,
      height: width * 290 / 200,
      child: CustomPaint(painter: _PackPainter(opened)),
    );
    if (!opened) return art;
    // Sobre abierto: 60 % de opacidad y colores apagados.
    return Opacity(
      opacity: 0.6,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.6, 0.3, 0.1, 0, 0, //
          0.15, 0.75, 0.1, 0, 0, //
          0.15, 0.3, 0.55, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
        child: art,
      ),
    );
  }
}

class _PackPainter extends CustomPainter {
  final bool opened;
  _PackPainter(this.opened);

  /// Borde dentado del sobre (función zig del mockup).
  Path _zig(double y) {
    final path = Path()..moveTo(14, y);
    for (double x = 14; x < 186; x += 8) {
      path.lineTo(x + 4, y + (y < 100 ? -6 : 6));
      path.lineTo(x + 8, y);
    }
    return path;
  }

  void _text(Canvas canvas, String text, double y, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    // En el SVG, `y` es la línea base del texto.
    painter.paint(
      canvas,
      Offset(
        100 - painter.width / 2,
        y - painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
      ),
    );
  }

    @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 290);
    const flap = Color(0xff155c3f);

    // Sombra bajo el sobre cerrado.
    if (!opened) {
      canvas.drawRRect(
        RRect.fromLTRBR(24, 60, 176, 280, const Radius.circular(10)),
        Paint()
          ..color = Court.c900.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }

    // Tapa superior dentada (solo cerrado).
    if (!opened) {
      canvas.drawPath(
        _zig(24)
          ..lineTo(186, 34)
          ..lineTo(14, 34)
          ..close(),
        Paint()..color = flap,
      );
    }

    // Cuerpo con degradado diagonal.
    final top = opened ? 44.0 : 30.0;
    final bodyRect = Rect.fromLTWH(14, top, 172, opened ? 222 : 236);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(10)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1d7550), Color(0xff072519)],
        ).createShader(bodyRect),
    );

    // Corte del sobre abierto.
    if (opened) {
      final cut = Path()..moveTo(14, 50);
      const points = [
        (30, 40),
        (44, 52),
        (60, 42),
        (76, 54),
        (92, 42),
        (108, 52),
        (124, 40),
        (140, 52),
        (156, 42),
        (172, 52),
        (186, 44),
      ];
      for (final (x, y) in points) {
        cut.lineTo(x.toDouble(), y.toDouble());
      }
      canvas.drawPath(
        cut,
        Paint()
          ..color = Court.c200
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Borde dentado inferior.
    canvas.drawPath(
      _zig(266)
        ..lineTo(186, 260)
        ..lineTo(14, 260)
        ..close(),
      Paint()..color = flap,
    );

        final lines = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(const Rect.fromLTWH(34, 62, 132, 176), lines);
    canvas.drawLine(const Offset(50, 62), const Offset(50, 238), lines);
    canvas.drawLine(const Offset(150, 62), const Offset(150, 238), lines);
    canvas.drawLine(const Offset(50, 104), const Offset(150, 104), lines);
    canvas.drawLine(const Offset(50, 196), const Offset(150, 196), lines);
    canvas.drawLine(const Offset(100, 104), const Offset(100, 196), lines);
    final net = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2;
    for (double x = 34; x < 166; x += 7) {
      canvas.drawLine(Offset(x, 150), Offset(x + 4, 150), net);
    }

    // Pelota de tenis al centro.
    canvas.drawCircle(const Offset(100, 150), 26, Paint()..color = Court.ball);
    final seam = Paint()
      ..color = Court.c900.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawPath(
      Path()
        ..moveTo(84, 131)
        ..arcToPoint(const Offset(84, 169), radius: const Radius.circular(26)),
      seam,
    );
    canvas.drawPath(
      Path()
        ..moveTo(116, 131)
        ..arcToPoint(
          const Offset(116, 169),
          radius: const Radius.circular(26),
          clockwise: false,
        ),
      seam,
    );

    // Textos.
    _text(
      canvas,
      kBrand.toUpperCase(),
      218,
      display(15, color: Colors.white).copyWith(letterSpacing: 2),
    );
    _text(
      canvas,
      'SOBRE DIARIO · 3 CARTAS',
      86,
      display(
        10,
        weight: FontWeight.w700,
        color: Court.ball,
      ).copyWith(letterSpacing: 2),
    );
  }

  @override
  bool shouldRepaint(_PackPainter old) => old.opened != opened;
}

