<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Miguel · Día 1 (miércoles 21): errores, widgets comunes, volteo y reverso

**Meta del día:** las piezas pequeñas que usan todas las pantallas: mensajes de error limpios, títulos, barras, cajas de estadística, avatar, reglas, borde discontinuo, la animación de volteo y el reverso de la carta.

← [Índice de guías](../README.md) · Siguiente: [Día 2](dia2.md)

## Mapa del día

| Paso | Qué haces | Archivo | Depende de |
|---|---|---|---|
| 0 | Clonar el proyecto y crear tu rama | (comandos) | Esqueleto de Sebastián (~10:00) |
| 1 | Mensajes de error limpios | `lib/presentation/errores.dart` | — |
| 2 | Volteo de carta | `lib/presentation/widgets/flip_card.dart` | — |
| 3 | Widgets comunes | `lib/presentation/widgets/common.dart` | Base visual de Sebastián (13:00) |
| 4 | Reverso de la carta | `lib/presentation/widgets/card_back.dart` | `court_lines.dart` de Emma |
| 5 | Mirar todo | `lib/muestra.dart` (no se sube) | — |
| 6 | Escenarios de prueba | `docs/escenarios-prueba.md` | — |

**Tiempo:** unas 3 h (~480 líneas) más los escenarios. Antes de empezar, lee [cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

---

## Paso 0 · Clonar y crear tu rama

Cuando Sebastián avise «Proyecto en main»:

```bash
git clone <url-del-repo> && cd SpinTCG
git switch -c miguel/dia1-comunes
cd app_flutter
flutter pub get
```

## Paso 1 · Mensajes de error limpios

Si una pantalla muestra la excepción tal cual, el usuario ve `Bad state: El sobre estará disponible mañana`. Solo debe ver el mensaje. **Crea**:

📄 **`app_flutter/lib/presentation/errores.dart`** · 9 líneas

```dart
/// Convierte una excepción en un mensaje para el usuario.
/// `StateError('El sobre estará disponible mañana')` se mostraría como
/// "Bad state: El sobre estará disponible mañana"; aquí queda solo el mensaje.
String mensajeDeError(Object error) => switch (error) {
  StateError(:final message) => message,
  ArgumentError(:final message) => '$message',
  FormatException(:final message) => message,
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
```

- `switch` con **patrones de objeto**: `StateError(:final message)` pregunta «¿es un `StateError`?» y, si lo es, saca su `message` en una variable.
- `ArgumentError.message` puede ser de cualquier tipo, por eso va dentro de `'$message'` (lo convierte en texto).
- El caso `_` atrapa cualquier otro error con un mensaje genérico. Nunca se muestra un error técnico al usuario.

## Paso 2 · El volteo de carta

**Crea**:

📄 **`app_flutter/lib/presentation/widgets/flip_card.dart`** · 40 líneas

```dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Gira una carta en 3D: muestra `back` y, al pasar `flipped` a true,
/// voltea en 0,55 s hasta mostrar `front`.
class FlipCard extends StatelessWidget {
  final bool flipped;
  final Widget back;
  final Widget front;
  const FlipCard({
    super.key,
    required this.flipped,
    required this.back,
    required this.front,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: flipped ? 1 : 0),
    duration: const Duration(milliseconds: 550),
    curve: const Cubic(0.2, 0.7, 0.2, 1),
    builder: (context, t, _) {
      final angle = t * pi; // 0 = reverso, π = frente
      final showFront = angle > pi / 2;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspectiva
          ..rotateY(angle),
        child: showFront
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi), // evita verla al revés
                child: front,
              )
            : back,
      );
    },
  );
}
```

- `TweenAnimationBuilder` anima un número de 0 a 1 cada vez que cambia `flipped`. No necesita `AnimationController` ni `StatefulWidget`.
- `Matrix4.rotateY(angle)` gira en 3D. `setEntry(3, 2, 0.001)` agrega **perspectiva**: sin ella, el giro se ve plano.
- A mitad del giro (`angle > π/2`) se cambia el reverso por el frente. El frente se gira otros 180° para que no se vea como en un espejo.
- `Cubic(0.2, 0.7, 0.2, 1)` es la misma curva de aceleración del mockup.

```bash
dart format lib && flutter analyze      # todavía no hay pruebas: llegan el jueves
git add -A && git commit -m "Errores limpios y volteo de carta"
```

## Paso 3 · Widgets comunes (después de la base de Sebastián)

```bash
git pull origin main     # trae theme.dart y TennisCard
```

Estos widgets aparecen en casi todas las pantallas. **Crea** el archivo en 5 partes.

📄 **`app_flutter/lib/presentation/widgets/common.dart`** · parte 1 de 5 (líneas 1–116) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../../domain/tennis_card.dart';
import '../theme.dart';

// --- Títulos y barras ---

/// Título grande de las pestañas (Colección, Sobres, Jugar).
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
```

- `ScreenTitle`: el título grande de las pestañas (Colección, Sobres, Jugar), con subtítulo y un botón opcional a la derecha (`trailing`).
- `TopBar`: la barra de las pantallas secundarias, con el botón ← redondo. `dark: true` es la versión para fondo verde (revelación del sobre).
- `?trailing` dentro de `children`: si `trailing` es `null`, no se agrega nada.
- `RoundIconButton`: el botón circular de 44 px (volver, cerrar partida). `tooltip` es el texto que lee TalkBack.

📄 **`app_flutter/lib/presentation/widgets/common.dart`** · parte 2 de 5 (líneas 118–206) · sigue debajo de la parte anterior

```dart
// --- Avisos y estadísticas ---

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

/// Caja con una estadística (Detalle y Perfil).
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
```

- `DemoTag` dice de dónde vienen los datos. Es la manera de **no presentar datos ficticios como reales**.
- `StatBox`: caja de estadística. Con `emphasis: true` va en verde oscuro (Ranking en Detalle, Cartas únicas en Perfil). `hint` es la línea chica de abajo, opcional.

📄 **`app_flutter/lib/presentation/widgets/common.dart`** · parte 3 de 5 (líneas 208–244) · sigue debajo de la parte anterior

```dart
// --- Avatar ---

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
```

- `Avatar` dibuja una silueta (cabeza y hombros) con un `CustomPainter`, sobre un círculo verde con borde verde limón.

📄 **`app_flutter/lib/presentation/widgets/common.dart`** · parte 4 de 5 (líneas 246–298) · sigue debajo de la parte anterior

```dart
// --- Reglas ---

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
              // La regla usa su ancho natural (como en el mockup), con tope
              // para que en pantallas angostas pase a dos líneas.
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
```

- `RulesList` recorre `Challenge.values`: si mañana se agrega un atributo, la lista crece sola.
- La regla tiene un ancho máximo (`ConstrainedBox`) y pasa a dos líneas en pantallas angostas.

📄 **`app_flutter/lib/presentation/widgets/common.dart`** · parte 5 de 5 (líneas 300–349) · sigue debajo de la parte anterior

```dart
// --- Borde discontinuo ---

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
```

- Flutter no trae un borde discontinuo. `DashedBorder` lo dibuja: recorre el contorno redondeado con `computeMetrics()` y pinta tramos de 6 px separados por 4 px.

```bash
dart format lib && flutter analyze
```

## Paso 4 · Reverso de la carta (después de `court_lines.dart` de Emma)

**Crea**:

📄 **`app_flutter/lib/presentation/widgets/card_back.dart`** · 93 líneas

```dart
import 'package:flutter/material.dart';
import '../theme.dart';
import 'court_lines.dart';

/// Reverso de una carta (sobre sin revelar y carta oculta del rival).
class CardBack extends StatelessWidget {
  final String? label;
  const CardBack({super.key, this.label});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 5 / 7,
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Court.c700, Court.c900],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 4,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CourtLines(opacity: 0.2),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Court.ball,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_baseball_outlined,
                  size: 26,
                  color: Court.c900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kBrand.toUpperCase(),
                style: display(
                  13,
                  color: Colors.white,
                ).copyWith(letterSpacing: 1.5),
              ),
              if (label != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    label!,
                    style: body(
                      11,
                      weight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
```

- Mismo tamaño (`AspectRatio 5/7`) y bordes que `PlayerCard`: al voltear, el frente calza exacto.
- `label` es opcional: «Toca para revelar» en el sobre y «Oculta» en la carta del rival.

## Paso 5 · Mirar todo

Crea `lib/muestra.dart` (está en `.gitignore` y no se sube):

📄 **`app_flutter/lib/muestra.dart`** · 95 líneas · **versión provisional**

```dart
// Pantalla de prueba para ver tus widgets sin tocar la app.
// Ejecutar: flutter run -t lib/muestra.dart   (NO se sube al repo)
import 'package:flutter/material.dart';
import 'presentation/theme.dart';
import 'presentation/widgets/card_back.dart';
import 'presentation/widgets/common.dart';
import 'presentation/widgets/flip_card.dart';

void main() => runApp(
  MaterialApp(
    theme: buildTheme(),
    home: const Scaffold(body: Muestra()),
  ),
);

class Muestra extends StatefulWidget {
  const Muestra({super.key});
  @override
  State<Muestra> createState() => _MuestraState();
}

class _MuestraState extends State<Muestra> {
  bool flipped = false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      children: [
        const ScreenTitle('Muestra', subtitle: 'Widgets comunes de Miguel'),
        const TopBar('Barra secundaria'),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: StatBox(
                      label: 'Ranking',
                      value: '#1',
                      emphasis: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: StatBox(
                      label: 'Títulos',
                      value: '19',
                      hint: 'mayor es mejor',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Avatar(size: 64),
              const SizedBox(height: 16),
              const RulesList(),
              const DemoTag(demo: true),
              const SizedBox(height: 16),
              const DashedBorder(
                child: SizedBox(
                  height: 60,
                  child: Center(child: Text('Borde discontinuo')),
                ),
              ),
              const SizedBox(height: 16),
              // Toca la carta para voltearla.
              GestureDetector(
                onTap: () => setState(() => flipped = !flipped),
                child: SizedBox(
                  width: 156,
                  child: AspectRatio(
                    aspectRatio: 5 / 7,
                    child: FlipCard(
                      flipped: flipped,
                      back: const CardBack(label: 'Toca para revelar'),
                      front: Container(
                        decoration: BoxDecoration(
                          color: Court.ball,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text('¡Frente!', style: display(20)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

```bash
flutter run -d linux -t lib/muestra.dart     # toca la carta para voltearla
dart format lib && flutter analyze
git add lib && git commit -m "Widgets comunes y reverso de carta"
git push -u origin miguel/dia1-comunes && gh pr create --fill
```

📣 Avisa en el chat: Emma (espacios del equipo, mañana a las 11:00) y Sebastián (Partida, el viernes) necesitan `common.dart` y `card_back.dart`.

## Paso 6 · Escenarios de prueba

Crea `docs/escenarios-prueba.md` con la tabla de la sección del miércoles de [`../../plan-crunch/miguel.md`](../../plan-crunch/miguel.md) (10 escenarios, con **pasos** y **resultado esperado**). Ojo: el apodo admite **16** caracteres.

## Cierre del día

- [ ] PR con `errores`, `flip_card`, `common` y `card_back`.
- [ ] `docs/escenarios-prueba.md` subido.
- [ ] Check-in de las 21:00.
