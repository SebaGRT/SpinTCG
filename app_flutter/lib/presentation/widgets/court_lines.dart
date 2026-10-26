import 'package:flutter/material.dart';

class CourtLines extends StatelessWidget {
  final double opacity;
  const CourtLines({super.key, this.opacity = 0.16});

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(child: CustomPaint(painter: _CourtPainter(opacity))),
  );
}

class _CourtPainter extends CustomPainter {
  final double opacity;
  _CourtPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(double x, double y) =>
        Offset(x * size.width / 100, y * size.height / 140);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRect(Rect.fromPoints(p(8, 8), p(92, 132)), line);
    canvas.drawLine(p(18, 8), p(18, 132), line);
    canvas.drawLine(p(82, 8), p(82, 132), line);
    canvas.drawLine(p(18, 40), p(82, 40), line);
    canvas.drawLine(p(18, 100), p(82, 100), line);
    canvas.drawLine(p(50, 40), p(50, 100), line);

    final net = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 1.6)
      ..strokeWidth = 1.4;

    final y = p(0, 70).dy;

    for (var x = p(8, 0).dx; x < p(92, 0).dx; x += 4) {
      canvas.drawLine(Offset(x, y), Offset(x + 2, y), net);
    }
  }

  @override
  bool shouldRepaint(_CourtPainter old) => old.opacity != opacity;
}
