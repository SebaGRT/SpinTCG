<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Emma · Día 1 (miércoles 21): la carta del tenista

**Meta del día:** la `PlayerCard` del mockup en sus tres tamaños (xs, sm y lg), además de la versión bloqueada «Sin obtener». Es la pieza más reutilizada de la app: aparece en Colección, Sobres, Detalle, Equipo y Partida.

← [Índice de guías](../README.md) · Siguiente: [Día 2](dia2.md)

## Mapa del día

| Paso | Qué haces | Archivo | Depende de |
|---|---|---|---|
| 0 | Clonar el proyecto y crear tu rama | (comandos) | Esqueleto de Sebastián (~10:00) |
| 1 | Nombres de países | `lib/presentation/widgets/countries.dart` | — |
| 2 | Líneas de la cancha | `lib/presentation/widgets/court_lines.dart` | — (📣 Miguel lo espera) |
| 3 | El tenista dibujado | `lib/presentation/widgets/player_figure.dart` | — |
| 4 | La carta | `lib/presentation/widgets/player_card.dart` | Base visual de Sebastián (13:00) |
| 5 | Mirar la carta | `lib/muestra.dart` (no se sube) | Catálogo demo de Sebastián (tarde) |

**Tiempo:** unas 3 h (~570 líneas). Antes de empezar, lee [cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

---

## Paso 0 · Clonar y crear tu rama

Cuando Sebastián avise «Proyecto en main»:

```bash
git clone <url-del-repo> && cd SpinTCG
git switch -c emma/dia1-carta
cd app_flutter
flutter pub get
```

## Paso 1 · Nombres de países

La API entrega códigos de tres letras (`ITA`). La carta grande y el Detalle muestran el nombre en español. **Crea**:

📄 **`app_flutter/lib/presentation/widgets/countries.dart`** · 39 líneas

```dart
// Nombre en español de los códigos de país que entrega la API (ITA → Italia).
// Si un código no está en la lista, se muestra el código tal cual.
const _countries = {
  'ARG': 'Argentina',
  'AUS': 'Australia',
  'AUT': 'Austria',
  'BEL': 'Bélgica',
  'BRA': 'Brasil',
  'BUL': 'Bulgaria',
  'CAN': 'Canadá',
  'CHI': 'Chile',
  'CHN': 'China',
  'COL': 'Colombia',
  'CRO': 'Croacia',
  'CZE': 'Chequia',
  'DEN': 'Dinamarca',
  'ESP': 'España',
  'FIN': 'Finlandia',
  'FRA': 'Francia',
  'GBR': 'Reino Unido',
  'GER': 'Alemania',
  'GRE': 'Grecia',
  'HUN': 'Hungría',
  'ITA': 'Italia',
  'JPN': 'Japón',
  'KAZ': 'Kazajistán',
  'NED': 'Países Bajos',
  'NOR': 'Noruega',
  'PER': 'Perú',
  'POL': 'Polonia',
  'POR': 'Portugal',
  'RUS': 'Rusia',
  'SRB': 'Serbia',
  'SUI': 'Suiza',
  'SWE': 'Suecia',
  'USA': 'Estados Unidos',
};

String countryName(String code) => _countries[code] ?? code;
```

- Es un `Map` constante: a la izquierda el código y a la derecha el nombre.
- `countryName()` usa `?? code`: si llega un código que no está en la lista, se muestra el código, nunca un error.
- Son los códigos de la ATP (`GER`, `SUI`, `NED`), no los ISO (`DEU`, `CHE`, `NLD`).

## Paso 2 · Líneas de la cancha

El fondo de la carta, del sobre y del banner de la partida lleva dibujada una cancha. **Crea**:

📄 **`app_flutter/lib/presentation/widgets/court_lines.dart`** · 48 líneas

```dart
import 'package:flutter/material.dart';

/// Líneas blancas de una cancha de tenis, dibujadas de fondo.
/// Se usa como hijo directo de un Stack (ocupa todo el espacio).
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
    // El dibujo original mide 100 × 140; se estira al tamaño disponible.
    Offset p(double x, double y) =>
        Offset(x * size.width / 100, y * size.height / 140);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRect(Rect.fromPoints(p(8, 8), p(92, 132)), line);
    canvas.drawLine(p(18, 8), p(18, 132), line); // pasillos de dobles
    canvas.drawLine(p(82, 8), p(82, 132), line);
    canvas.drawLine(p(18, 40), p(82, 40), line); // líneas de saque
    canvas.drawLine(p(18, 100), p(82, 100), line);
    canvas.drawLine(p(50, 40), p(50, 100), line); // línea central

    // Red: línea discontinua en la mitad.
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
```

- `CustomPainter` dibuja con instrucciones de bajo nivel: `drawRect`, `drawLine`.
- El mockup dibuja la cancha en un SVG de 100 × 140. La función `p(x, y)` convierte esas coordenadas al tamaño real del widget.
- `Positioned.fill` hace que el dibujo ocupe todo el `Stack` donde se pone. `IgnorePointer` evita que el dibujo «se coma» los toques.
- `shouldRepaint` le dice a Flutter cuándo volver a dibujar: solo si cambia la opacidad.

```bash
dart format lib && flutter analyze
git add -A && git commit -m "Países y líneas de cancha"
git push -u origin emma/dia1-carta && gh pr create --fill
```

📣 Avisa a Miguel: necesita `court_lines.dart` para el reverso de la carta.

## Paso 3 · El tenista dibujado

El mockup no usa fotos (por derechos de autor), sino un tenista dibujado con colores que cambian según la carta. **Crea** el archivo en 4 partes.

📄 **`app_flutter/lib/presentation/widgets/player_figure.dart`** · parte 1 de 4 (líneas 1–32) · empieza el archivo

```dart
import 'dart:math';
import 'package:flutter/material.dart';

// --- Colores ---

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
```

- Tres listas de colores (piel, pelo y polera) y el gris de la silueta.
- Empiezan con `_`: son privadas, solo se usan en este archivo.

📄 **`app_flutter/lib/presentation/widgets/player_figure.dart`** · parte 2 de 4 (líneas 34–55) · sigue debajo de la parte anterior

```dart
// --- El widget ---

/// Ilustración del tenista con raqueta (reemplaza la foto).
/// `seed` elige los colores: misma carta → mismo dibujo.
/// Con `silhouette: true` se dibuja la silueta gris de una carta bloqueada.
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
```

- `seed` es el número de la carta: la misma carta siempre se ve igual.
- `silhouette: true` pinta todo gris: es la carta «Sin obtener».
- `Align` + `AspectRatio(100 / 120)` mantienen la proporción del dibujo original, pegado abajo.

📄 **`app_flutter/lib/presentation/widgets/player_figure.dart`** · parte 3 de 4 (líneas 57–105) · sigue debajo de la parte anterior

```dart
// --- El dibujo: raqueta ---

class _FigurePainter extends CustomPainter {
  final int seed;
  final bool silhouette;
  _FigurePainter(this.seed, this.silhouette);

  @override
  void paint(Canvas canvas, Size size) {
    // Coordenadas del SVG original: 100 de ancho × 120 de alto.
    canvas.scale(size.width / 100, size.height / 120);
    final skin = silhouette ? _silhouette : _skin[(seed * 3) % _skin.length];
    final hair = silhouette ? _silhouette : _hair[(seed * 7) % _hair.length];
    final shirt = silhouette ? _silhouette : _shirt[(seed * 5) % _shirt.length];
    Paint fill(Color c) => Paint()..color = c;

    // Raqueta, girada -24° alrededor de (78, 52).
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
```

- `canvas.scale` permite dibujar con las coordenadas del SVG (100 × 120), sin hacer cuentas.
- `(seed * 3) % 5` elige uno de los 5 tonos de piel. Al multiplicar por números distintos (3, 7, 5), cartas vecinas salen con combinaciones distintas.
- `save()` → `translate` → `rotate` → `restore()` gira **solo la raqueta** (-24°) sin girar el resto.

📄 **`app_flutter/lib/presentation/widgets/player_figure.dart`** · parte 4 de 4 (líneas 107–161) · sigue debajo de la parte anterior

```dart
    // --- El dibujo: cuerpo y cabeza ---

    // Torso (polera).
    final torso = Path()
      ..moveTo(14, 120)
      ..cubicTo(14, 94, 29, 80, 50, 80)
      ..cubicTo(71, 80, 86, 94, 86, 120)
      ..close();
    canvas.drawPath(torso, fill(shirt));

    // Cuello de la polera.
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

    // Cuello y cabeza.
    canvas.drawRRect(
      RRect.fromLTRBR(43, 62, 57, 80, const Radius.circular(6)),
      fill(skin),
    );
    canvas.drawCircle(const Offset(50, 48), 17, fill(skin));

    // Pelo.
    final hairPath = Path()
      ..moveTo(33, 46)
      ..cubicTo(33, 34, 40, 27, 50, 27)
      ..cubicTo(60, 27, 67, 34, 67, 45)
      ..cubicTo(63, 39, 57, 37, 50, 37)
      ..cubicTo(43, 37, 38, 40, 33, 46)
      ..close();
    canvas.drawPath(hairPath, fill(hair));

    // Cintillo blanco.
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
```

- `Path` con `cubicTo` dibuja curvas, como las de un SVG (torso y pelo).
- Se dibuja en orden, de atrás hacia adelante: torso, cuello, cabeza, pelo y cintillo.

```bash
dart format lib && flutter analyze
git add -A && git commit -m "Tenista dibujado"
```

## Paso 4 · La carta (después de la base visual de Sebastián)

```bash
git pull origin main     # trae theme.dart y TennisCard
```

**Crea** el archivo en 5 partes. Este lo vas a explicar en la presentación.

📄 **`app_flutter/lib/presentation/widgets/player_card.dart`** · parte 1 de 5 (líneas 1–73) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../../domain/tennis_card.dart';
import '../theme.dart';
import 'countries.dart';
import 'court_lines.dart';
import 'player_figure.dart';

// --- Formato y tamaños ---

/// Valor de un atributo como lo muestra el mockup: #8 · 3 · 61% (o 61.3%).
String formatStat(TennisCard card, Challenge challenge) => switch (challenge) {
  Challenge.ranking => '#${card.ranking}',
  Challenge.titles => '${card.titles}',
  Challenge.winRate =>
    card.winRate == card.winRate.roundToDouble()
        ? '${card.winRate.toInt()}%'
        : '${card.winRate.toStringAsFixed(1)}%',
};

/// xs: equipo y partida · sm: colección y sobre · lg: detalle.
enum CardSize { xs, sm, lg }

/// Medidas de cada tamaño (tabla CARD de ui.tsx).
class _Style {
  final double pad, radius, inner, rank, last, first, meta;
  final EdgeInsets rankPad, bodyPad;
  const _Style(
    this.pad,
    this.radius,
    this.inner,
    this.rank,
    this.last,
    this.first,
    this.meta,
    this.rankPad,
    this.bodyPad,
  );
  static _Style of(CardSize size) => switch (size) {
    CardSize.xs => const _Style(
      4,
      14,
      10,
      11,
      12.5,
      9.5,
      10,
      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      EdgeInsets.fromLTRB(4, 6, 4, 2),
    ),
    CardSize.sm => const _Style(
      6,
      18,
      13,
      13,
      16,
      11,
      11.5,
      EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      EdgeInsets.fromLTRB(6, 8, 6, 4),
    ),
    CardSize.lg => const _Style(
      8,
      24,
      18,
      17,
      24,
      13,
      13,
      EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      EdgeInsets.fromLTRB(10, 12, 10, 8),
    ),
  };
}
```

- `formatStat()` muestra cada atributo como en el mockup: `#8`, `3` y `61%` (o `61.3%` si tiene decimales). También la usan la Partida y el Resultado.
- **Un widget, tres tamaños.** `CardSize` elige una fila de `_Style` (relleno, radios y tamaños de letra), copiada de la tabla `CARD` de `ui.tsx` del mockup. Así no hay tres widgets casi iguales.

📄 **`app_flutter/lib/presentation/widgets/player_card.dart`** · parte 2 de 5 (líneas 75–146) · sigue debajo de la parte anterior

```dart
// --- La carta ---

/// La carta de tenista del mockup. Con `locked: true` muestra la carta
/// "Sin obtener" con la silueta gris.
class PlayerCard extends StatelessWidget {
  final TennisCard card;
  final int number; // N.º en el álbum (1 a 24)
  final int total; // cartas del catálogo
  final int copies;
  final CardSize size;
  final bool locked;
  final bool inTeam;
  final VoidCallback? onTap;

  const PlayerCard({
    super.key,
    required this.card,
    required this.number,
    this.total = 24,
    this.copies = 0,
    this.size = CardSize.sm,
    this.locked = false,
    this.inTeam = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = _Style.of(size);
    final content = AspectRatio(
      aspectRatio: 5 / 7,
      child: Container(
        padding: EdgeInsets.all(s.pad),
        decoration: BoxDecoration(
          color: locked ? Court.locked : Colors.white,
          borderRadius: BorderRadius.circular(s.radius),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: locked
              ? null
              : [
                  BoxShadow(
                    color: Court.c900.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Court.c900.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: -8,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _portrait(s)),
            Padding(
              padding: s.bodyPad,
              child: locked ? _lockedBody(s) : _body(s),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: card.name,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }
```

- `AspectRatio(5 / 7)`: la carta siempre tiene la proporción de una carta física, sea cual sea su ancho.
- La carta es un `Column`: arriba el retrato (`Expanded`, ocupa lo que sobra) y abajo los datos.
- Si recibe `onTap`, se envuelve en `Semantics(button: true, label: card.name)`. TalkBack lee el nombre del tenista, y las pruebas pueden buscar la carta por ese nombre.

📄 **`app_flutter/lib/presentation/widgets/player_card.dart`** · parte 3 de 5 (líneas 148–243) · sigue debajo de la parte anterior

```dart
  // --- Retrato ---

  Widget _portrait(_Style s) => ClipRRect(
    borderRadius: BorderRadius.circular(s.inner),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: locked ? Court.lockedInner : null,
        gradient: locked
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Court.c700, Court.c900],
              ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!locked) const CourtLines(),
          PlayerFigure(seed: number - 1, silhouette: locked),
          Positioned(
            left: 6,
            top: 6,
            child: _chip(
              locked ? '#—' : '#${card.ranking}',
              background: locked
                  ? Colors.white.withValues(alpha: 0.7)
                  : Court.ball,
              style: display(
                s.rank,
                color: locked ? Court.muted : Court.c900,
                weight: locked ? FontWeight.w700 : FontWeight.w800,
              ),
              padding: s.rankPad,
            ),
          ),
          if (!locked)
            Positioned(
              right: 6,
              top: 6,
              child: _chip(
                card.country,
                background: Colors.black.withValues(alpha: 0.25),
                style: display(
                  size == CardSize.xs ? 9 : 11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ).copyWith(letterSpacing: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          if (inTeam && !locked)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 11, color: Court.c800),
                    const SizedBox(width: 2),
                    Text(
                      'En equipo',
                      style: body(
                        size == CardSize.xs ? 9 : 10.5,
                        weight: FontWeight.w700,
                        color: Court.c800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _chip(
    String text, {
    required Color background,
    required TextStyle style,
    required EdgeInsets padding,
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: style),
  );
```

- El retrato es un `Stack`, en capas: degradado → líneas de cancha → tenista → *chips* de ranking y país → insignia «En equipo».
- `Positioned(left: 6, top: 6)` ubica cada chip en una esquina.
- `_chip()` es un ayudante para no repetir el mismo `Container` tres veces.

📄 **`app_flutter/lib/presentation/widgets/player_card.dart`** · parte 4 de 5 (líneas 245–305) · sigue debajo de la parte anterior

```dart
  // --- Nombre, país y copias ---

  Widget _body(_Style s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (size != CardSize.xs)
        Text(
          card.firstName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: body(s.first, weight: FontWeight.w500, color: Court.muted),
        ),
      Text(
        card.lastName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: display(s.last, color: Court.ink),
      ),
      const SizedBox(height: 2),
      Row(
        children: [
          Expanded(
            child: Text(
              size == CardSize.xs ? card.country : countryName(card.country),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body(s.meta, color: Court.muted),
            ),
          ),
          if (copies > 0 && size != CardSize.xs) _copiesChip(s),
        ],
      ),
    ],
  );

  Widget _copiesChip(_Style s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: copies > 1 ? Court.ball.withValues(alpha: 0.6) : Court.c50,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.copy_rounded,
          size: 11,
          color: copies > 1 ? Court.c900 : Court.c700,
        ),
        const SizedBox(width: 2),
        Text(
          '×$copies',
          style: display(
            s.meta,
            weight: FontWeight.w700,
            color: copies > 1 ? Court.c900 : Court.c700,
          ),
        ),
      ],
    ),
  );
```

- En tamaño xs no se muestra el nombre de pila ni las copias: no caben.
- `Expanded` con `TextOverflow.ellipsis`: *Davidovich Fokina* termina en «…» en vez de desbordar.
- Con 2 o más copias, el chip se pinta verde limón para destacarlas.

📄 **`app_flutter/lib/presentation/widgets/player_card.dart`** · parte 5 de 5 (líneas 307–341) · sigue debajo de la parte anterior

```dart
  // --- Carta bloqueada ---

  Widget _lockedBody(_Style s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: size == CardSize.lg ? 18 : 13,
            color: Court.muted,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Sin obtener',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: display(
                s.last,
                weight: FontWeight.w700,
                color: Court.muted,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        'N.º ${number.toString().padLeft(2, '0')} de $total',
        style: body(s.meta, color: Court.disabledText),
      ),
    ],
  );
}
```

- La carta bloqueada no muestra datos del tenista: solo el candado, «Sin obtener» y su número en el álbum (`padLeft(2, '0')` convierte 5 en `05`).

## Paso 5 · Mirar la carta

La carta todavía no aparece en la app (Colección llega el viernes). Para verla, crea `lib/muestra.dart` (está en `.gitignore` y no se sube):

📄 **`app_flutter/lib/muestra.dart`** · 75 líneas · **versión provisional**

```dart
// Pantalla de prueba para ver tus cartas sin tocar la app.
// Ejecutar: flutter run -t lib/muestra.dart   (NO se sube al repo)
import 'package:flutter/material.dart';
import 'data/demo_catalog.dart';
import 'presentation/theme.dart';
import 'presentation/widgets/player_card.dart';

void main() {
  final cards = demoCatalog();
  runApp(
    MaterialApp(
      theme: buildTheme(),
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // sm: obtenida, bloqueada, en el equipo y con copias.
              Row(
                children: [
                  Expanded(
                    child: PlayerCard(card: cards[0], number: 1, copies: 1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PlayerCard(card: cards[1], number: 2, locked: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PlayerCard(
                      card: cards[14], // nombre largo: Félix Auger-Aliassime
                      number: 15,
                      copies: 3,
                      inTeam: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // xs: tamaño de equipo y partida.
                  Expanded(
                    child: Row(
                      children: [
                        for (final i in [3, 6]) ...[
                          Expanded(
                            child: PlayerCard(
                              card: cards[i],
                              number: i + 1,
                              size: CardSize.xs,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // lg: tamaño del Detalle.
              PlayerCard(
                card: cards[7],
                number: 8,
                copies: 2,
                size: CardSize.lg,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

```bash
flutter run -d linux -t lib/muestra.dart
```

Compara con el mockup: chip verde limón con el ranking, código de país arriba a la derecha, nombre chico y apellido grande, y la carta gris con candado. Prueba también con la ventana angosta.

```bash
dart format lib && flutter analyze      # todavía no hay pruebas: llegan el jueves
git add lib/presentation && git commit -m "Carta de tenista del mockup en tres tamaños"
git push
```

## Cierre del día

- [ ] PR con `countries`, `court_lines`, `player_figure` y `player_card`.
- [ ] Sabes explicar `_Style`, `AspectRatio` y por qué el texto no desborda.
- [ ] Check-in de las 21:00.
