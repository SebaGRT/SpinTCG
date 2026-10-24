<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Miguel · Día 2 (jueves 22): el sobre, Sobres y la revelación

**Meta del día:** la pestaña Sobres del mockup y la pantalla verde oscura donde se revelan las tres cartas tocándolas una por una. Al cierre, abrir un sobre ya se ve como en el diseño.

← [Día 1](dia1.md) · [Índice](../README.md) · Siguiente: [Día 3](dia3.md)

## Mapa del día

| Paso | Qué haces | Archivo | Depende de |
|---|---|---|---|
| 1 | El dibujo del sobre | `lib/presentation/widgets/pack_art.dart` | — |
| 2 | Pantalla de revelación | `lib/presentation/reveal_page.dart` | `player_card.dart` (Emma) y `navigation.dart` (Sebastián, 10:00) |
| 3 | Pestaña Sobres | `lib/presentation/packs_page.dart` | — |
| 4 | Conectar la pestaña Sobres | `lib/presentation/app_shell.dart` (1 línea + import) | Cáscara de Sebastián (hoy) |

**Tiempo:** unas 3,5 h (~580 líneas). [Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

```bash
git switch main && git pull
git switch -c miguel/dia2-sobres
cd app_flutter
```

---

## Paso 1 · El dibujo del sobre

**Crea** el archivo en 4 partes.

📄 **`app_flutter/lib/presentation/widgets/pack_art.dart`** · parte 1 de 4 (líneas 1–34) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../theme.dart';

// --- El widget ---

/// Ilustración del sobre diario. Abierto se ve más pálido y sin la tapa.
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
```

- El alto se calcula del ancho (`width * 290 / 200`) para mantener la proporción del sobre.
- **Sobre abierto:** se envuelve en `ColorFiltered` (una matriz que mezcla los canales de color y los apaga) más un 60 % de opacidad.

📄 **`app_flutter/lib/presentation/widgets/pack_art.dart`** · parte 2 de 4 (líneas 36–65) · sigue debajo de la parte anterior

```dart
// --- Ayudantes del dibujo ---

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
```

- `_zig()` arma el borde dentado con un `Path` que sube y baja cada 8 px.
- `_text()` dibuja texto con `TextPainter`: dentro de un `CustomPainter` no se pueden usar widgets `Text`.

📄 **`app_flutter/lib/presentation/widgets/pack_art.dart`** · parte 3 de 4 (líneas 67–143) · sigue debajo de la parte anterior

```dart
  // --- El dibujo: sobre ---

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
```

- Todo se dibuja en un lienzo de **200 × 290** (las medidas del SVG del mockup), y `canvas.scale(...)` lo ajusta al tamaño real. Así las coordenadas se copian tal cual del diseño.
- Se dibuja en capas: sombra, tapa dentada (solo cerrado), cuerpo con degradado, corte (solo abierto) y borde inferior.
- El degradado es un `Shader` creado con `LinearGradient.createShader(rect)`.

📄 **`app_flutter/lib/presentation/widgets/pack_art.dart`** · parte 4 de 4 (líneas 145–209) · sigue debajo de la parte anterior

```dart
    // --- El dibujo: cancha, pelota y textos ---

    // Cancha dibujada en el sobre.
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
```

- Encima del cuerpo van la cancha, la pelota con sus dos costuras (`arcToPoint`) y los textos con `kBrand`.

Pruébalo con esta muestra (`lib/muestra.dart`, que no se sube):

📄 **`app_flutter/lib/muestra.dart`** · 18 líneas · **versión provisional**

```dart
// Pantalla de prueba del sobre. Ejecutar: flutter run -t lib/muestra.dart
import 'package:flutter/material.dart';
import 'presentation/theme.dart';
import 'presentation/widgets/pack_art.dart';

void main() => runApp(
  MaterialApp(
    theme: buildTheme(),
    home: const Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [PackArt(width: 150), PackArt(width: 150, opened: true)],
        ),
      ),
    ),
  ),
);
```

```bash
flutter run -d linux -t lib/muestra.dart
dart format lib && flutter analyze && flutter test
git add lib/presentation && git commit -m "Dibujo del sobre"
```

## Paso 2 · Pantalla de revelación

**Crea** el archivo en 3 partes.

📄 **`app_flutter/lib/presentation/reveal_page.dart`** · parte 1 de 3 (líneas 1–21) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/card_back.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/flip_card.dart';
import 'widgets/player_card.dart';

// --- Datos de cada carta ---

/// Una carta del sobre: si es nueva y cuántas copias quedan.
class PackCard {
  final TennisCard card;
  final bool isNew;
  final int copies;
  const PackCard(this.card, {required this.isNew, required this.copies});
}
```

- `PackCard` junta lo que la pantalla necesita saber de cada carta: el tenista, si es **nueva** y cuántas copias tienes ahora.

📄 **`app_flutter/lib/presentation/reveal_page.dart`** · parte 2 de 3 (líneas 23–129) · sigue debajo de la parte anterior

```dart
// --- La pantalla ---

/// Pantalla oscura donde se revelan las tres cartas del sobre.
class RevealPage extends StatefulWidget {
  final AppController app;
  final List<PackCard> cards;
  const RevealPage({super.key, required this.app, required this.cards});
  @override
  State<RevealPage> createState() => _RevealPageState();
}

class _RevealPageState extends State<RevealPage> {
  final revealed = <int>{};

  @override
  Widget build(BuildContext context) {
    final done = revealed.length == widget.cards.length;
    return Scaffold(
      backgroundColor: Court.c900,
      body: Stack(
        children: [
          const CourtLines(opacity: 0.07),
          SafeArea(
            child: Column(
              children: [
                TopBar(
                  'Sobre diario',
                  dark: true,
                  onBack: () => Navigator.pop(context),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${revealed.length} de 3 reveladas',
                      style: body(
                        13,
                        weight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                Text(
                  done
                      ? 'Cartas añadidas a tu colección'
                      : 'Toca cada carta para revelarla',
                  style: body(14, color: Colors.white.withValues(alpha: 0.7)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _card(0),
                            const SizedBox(width: 16),
                            _card(1),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _card(2),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: done
                      ? CourtButton(
                          'Ver colección',
                          variant: ButtonVariant.accent,
                          size: ButtonSize.lg,
                          iconRight: Icons.chevron_right,
                          full: true,
                          onPressed: () => goToTab(context, Tabs.collection),
                        )
                      : SizedBox(
                          height: 56,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < 3; i++)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: revealed.contains(i)
                                        ? Court.ball
                                        : Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                            ],
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

- `revealed` es un `Set<int>` con las cartas ya tocadas. Cuando tiene las 3 (`done`), cambia el texto de arriba y aparece «Ver colección».
- Las cartas van en dos filas: 2 arriba y 1 abajo, como en el mockup.
- Mientras faltan cartas, abajo se ven 3 puntos que se encienden al revelar.
- «Ver colección» usa `goToTab`: cierra esta pantalla y muestra la pestaña Colección.

📄 **`app_flutter/lib/presentation/reveal_page.dart`** · parte 3 de 3 (líneas 131–194) · sigue debajo de la parte anterior

```dart
  // --- Una carta y su etiqueta ---

  Widget _card(int i) {
    if (i >= widget.cards.length) return const SizedBox.shrink();
    final pack = widget.cards[i];
    final shown = revealed.contains(i);
    return SizedBox(
      width: 156,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Semantics(
            button: !shown,
            label: shown ? null : 'Revelar carta ${i + 1}',
            child: GestureDetector(
              onTap: shown ? null : () => setState(() => revealed.add(i)),
              child: FlipCard(
                flipped: shown,
                back: const CardBack(label: 'Toca para revelar'),
                front: PlayerCard(
                  card: pack.card,
                  number: widget.app.numberOf(pack.card),
                  total: widget.app.catalog.length,
                  copies: pack.copies,
                ),
              ),
            ),
          ),
          if (shown) Positioned(top: -12, child: _badge(pack)),
        ],
      ),
    );
  }

  /// Etiqueta "Nueva" o "Duplicada · ×N" sobre la carta revelada.
  Widget _badge(PackCard pack) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: pack.isNew ? Court.ball : Colors.white,
      borderRadius: BorderRadius.circular(99),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          pack.isNew ? Icons.star_rounded : Icons.copy_rounded,
          size: 13,
          color: pack.isNew ? Court.c900 : Court.c800,
        ),
        const SizedBox(width: 4),
        Text(
          pack.isNew ? 'Nueva' : 'Duplicada · ×${pack.copies}',
          style: body(
            12,
            weight: FontWeight.w700,
            color: pack.isNew ? Court.c900 : Court.c800,
          ),
        ),
      ],
    ),
  );
}
```

- Cada carta es un `FlipCard` (tu widget de ayer) que pasa del `CardBack` a la `PlayerCard`.
- `Semantics(label: 'Revelar carta N')`: TalkBack dice qué hace cada carta, y la prueba de interfaz la toca por esa etiqueta.
- La insignia «Nueva» o «Duplicada · ×N» va en un `Positioned(top: -12)` con `clipBehavior: Clip.none`: sobresale de la carta como en el mockup.

## Paso 3 · Pestaña Sobres

**Crea** el archivo en 3 partes. Aquí está la lógica que vas a explicar.

📄 **`app_flutter/lib/presentation/packs_page.dart`** · parte 1 de 3 (líneas 1–42) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'errores.dart';
import 'navigation.dart';
import 'reveal_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/pack_art.dart';

// --- Abrir el sobre ---

class PacksPage extends StatelessWidget {
  final AppController app;
  const PacksPage({super.key, required this.app});

  Future<void> _open(BuildContext context) async {
    // Copias antes de abrir, para saber si cada carta es nueva o duplicada.
    final before = Map<String, int>.of(app.copies);
    try {
      final cards = await app.openPack();
      final revealed = <PackCard>[];
      for (final card in cards) {
        final copies = (before[card.id] ?? 0) + 1;
        revealed.add(PackCard(card, isNew: copies == 1, copies: copies));
        before[card.id] = copies;
      }
      if (context.mounted) {
        await openPage(
          context,
          app,
          () => RevealPage(app: app, cards: revealed),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }
```

- `_open()` copia las copias **antes** de abrir (`before`). Así se sabe si cada carta es nueva. Si el mismo tenista sale dos veces en el mismo sobre, la segunda ya cuenta como duplicada, porque `before[card.id]` se actualiza dentro del ciclo.
- `openPack()` está protegido en el controlador: si ya se abrió hoy, lanza `StateError` y `mensajeDeError` muestra «El sobre estará disponible mañana».
- `context.mounted` después de cada `await`: la pantalla pudo cerrarse mientras se guardaba, y usar un `context` cerrado es un error.

📄 **`app_flutter/lib/presentation/packs_page.dart`** · parte 2 de 3 (líneas 44–150) · sigue debajo de la parte anterior

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final opened = !app.canOpenPack;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const ScreenTitle(
                'Sobres',
                subtitle: 'Un sobre gratuito cada día',
              ),
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _ring(320, Court.c100),
                    _ring(256, Court.c200),
                    PackArt(width: 190, opened: opened),
                    if (opened) _openedChip(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                opened ? 'Sobre de hoy abierto' : 'Sobre diario',
                style: display(24),
              ),
              const SizedBox(height: 6),
              opened
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 17,
                          color: Court.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Disponible mañana',
                          style: body(15, color: Court.muted),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: 260,
                      child: Text(
                        'Obtén tres cartas aleatorias para tu colección',
                        textAlign: TextAlign.center,
                        style: body(15, color: Court.muted),
                      ),
                    ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _tag('3 cartas'),
                    _tag('Gratis cada día'),
                    _tag('Las repetidas suman copias'),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: opened
                    ? Column(
                        children: [
                          const CourtButton(
                            'Disponible mañana',
                            size: ButtonSize.lg,
                            icon: Icons.schedule,
                            full: true,
                          ),
                          const SizedBox(height: 8),
                          CourtButton(
                            'Ver colección',
                            variant: ButtonVariant.ghost,
                            full: true,
                            onPressed: () => goToTab(context, Tabs.collection),
                          ),
                        ],
                      )
                    : CourtButton(
                        'Abrir sobre',
                        variant: ButtonVariant.accent,
                        size: ButtonSize.lg,
                        icon: Icons.inventory_2_outlined,
                        full: true,
                        onPressed: app.busy ? null : () => _open(context),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
```

- `SliverFillRemaining(hasScrollBody: false)` + `Spacer()`: el botón queda abajo si sobra espacio, y la pantalla se puede desplazar si falta (teléfonos chicos).
- Sobre abierto: se ve apagado con «Abierto» encima, el botón queda deshabilitado («Disponible mañana») y aparece un acceso a Colección.
- Las etiquetas van en un `Wrap`: si no caben en una línea, pasan a la siguiente.

📄 **`app_flutter/lib/presentation/packs_page.dart`** · parte 3 de 3 (líneas 152–196) · sigue debajo de la parte anterior

```dart
  // --- Piezas pequeñas ---

  Widget _ring(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color),
    ),
  );

  Widget _openedChip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: Court.line),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 16, color: Court.c800),
        const SizedBox(width: 6),
        Text(
          'Abierto',
          style: body(13, weight: FontWeight.w700, color: Court.c800),
        ),
      ],
    ),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Court.c50,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: Court.c100),
    ),
    child: Text(
      text,
      style: body(12, weight: FontWeight.w500, color: Court.c800),
    ),
  );
}
```

- Tres piezas pequeñas para no repetir código: los anillos detrás del sobre, la etiqueta «Abierto» y cada etiqueta de abajo.

## Paso 4 · Conectar la pestaña Sobres

En `lib/presentation/app_shell.dart` (de Sebastián), agrega el import (en orden alfabético, con los otros):

```dart
import 'packs_page.dart';
```

Y cambia la línea de la pestaña provisional:

```dart
              PacksPage(app: app),   // en lugar de const PantallaPendiente('Sobres', …)
```

```bash
dart format lib && flutter analyze && flutter test
flutter run -d linux
```

Sobres → Abrir sobre → toca las 3 cartas (cada una se voltea y muestra «Nueva» o «Duplicada») → Ver colección. Vuelve a Sobres: «Sobre de hoy abierto» y botón deshabilitado. La barra inferior ya no muestra el punto rojo.

```bash
git add -A && git commit -m "Pestaña Sobres y revelación con volteo"
git push -u origin miguel/dia2-sobres && gh pr create --fill
```

> Para volver a probar la apertura, borra el progreso guardado: en Linux es `spintcg_demo.json` en la carpeta de documentos de tu usuario (`~/Documents` o `~/Documentos`); en Android, desinstala la app o borra sus datos.

## Cierre del día

- [ ] PR de Sobres.
- [ ] Sabes explicar `before`, `context.mounted` y por qué el sobre se dibuja en 200 × 290.
- [ ] Check-in de las 21:00.
