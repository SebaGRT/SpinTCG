import 'package:flutter/material.dart';
import '../../domain/tennis_card.dart';
import '../theme.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const ScreenTitle(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: display(30, height: 1)),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: body(14, color: Court.muted)),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Barra de las pantallas secundarias: botón volver redondo + título.
class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool dark;
  const TopBar(
    this.title, {
    super.key,
    this.onBack,
    this.trailing,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (onBack != null) ...[
            RoundIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: 'Volver',
              onPressed: onBack!,
              dark: dark,
            ),
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: display(
                17,
                weight: FontWeight.w700,
                color: dark ? Colors.white : Court.ink,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}

/// Botón circular de 44 px (volver, cerrar partida).
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool dark;
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    iconSize: 20,
    style: IconButton.styleFrom(
      fixedSize: const Size(44, 44),
      backgroundColor: dark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white,
      foregroundColor: dark ? Colors.white : Court.c900,
      side: dark ? BorderSide.none : const BorderSide(color: Court.line),
    ),
    icon: Icon(icon),
  );
}

/// Aviso pequeño del origen de los datos.
class DemoTag extends StatelessWidget {
  final bool demo;
  final bool dark;
  const DemoTag({super.key, required this.demo, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final color = dark
        ? Colors.white.withValues(alpha: 0.55)
        : Court.muted.withValues(alpha: 0.8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          demo ? 'Datos de demostración' : 'Datos de RapidAPI · carrera',
          style: body(11, weight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}

/// Caja con estadística (Detalle y Perfil).
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final bool emphasis; // fondo verde oscuro
  const StatBox({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: emphasis ? Court.c800 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: emphasis ? null : Border.all(color: Court.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: body(
            11.5,
            weight: FontWeight.w600,
            color: emphasis ? Court.ball : Court.muted,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: display(26, color: emphasis ? Colors.white : Court.ink),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(
            hint!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body(
              10.5,
              color: emphasis
                  ? Colors.white.withValues(alpha: 0.6)
                  : Court.muted,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Avatar predeterminado: silueta verde limón sobre círculo verde.
class Avatar extends StatelessWidget {
  final double size;
  const Avatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Court.c700,
      shape: BoxShape.circle,
      border: Border.all(color: Court.ball, width: 2),
    ),
    child: ClipOval(child: CustomPaint(painter: _AvatarPainter())),
  );
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 40);
    final paint = Paint()..color = Court.ball;
    canvas.drawCircle(const Offset(20, 16), 7, paint);
    final shoulders = Path()
      ..moveTo(6, 40)
      ..cubicTo(7, 31, 13, 26, 20, 26)
      ..cubicTo(27, 26, 33, 31, 34, 40)
      ..close();
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(_AvatarPainter old) => false;
}

/// Las tres reglas de la partida, numeradas.
class RulesList extends StatelessWidget {
  const RulesList({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final c in Challenge.values)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Court.line),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Court.c800,
                child: Text(
                  '${c.index + 1}',
                  style: display(
                    13,
                    weight: FontWeight.w700,
                    color: Court.ball,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(c.label, style: body(14, weight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              // La regla usa su ancho natural, con tope para que
              // en pantallas angostas pase a dos líneas.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  c.rule,
                  textAlign: TextAlign.end,
                  style: body(12.5, color: Court.muted),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// Recuadro con borde discontinuo (espacios vacíos y estados vacíos).
class DashedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;
  final Color? fill;
  const DashedBorder({
    super.key,
    required this.child,
    this.radius = 14,
    this.color = Court.c200,
    this.fill,
  });

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DashedPainter(radius, color, fill), child: child);
}

class _DashedPainter extends CustomPainter {
  final double radius;
  final Color color;
  final Color? fill;
  _DashedPainter(this.radius, this.color, this.fill);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      Radius.circular(radius),
    );
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // Recorre el contorno y dibuja tramos de 6 px separados por 4 px.
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 6), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.radius != radius || old.fill != fill;
}
