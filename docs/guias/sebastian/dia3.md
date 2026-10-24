<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Sebastián · Día 3 (viernes 23): Partida, Jugar, Android y plan B

**Meta del día:**
- **Antes de las 12:00:** la pantalla **Partida**, en `main`. Miguel la necesita para conectar su pantalla Resultado.
- **Antes de las 14:00:** la pestaña **Jugar** y la **decisión de plan B**.
- **Tarde:** la app completa corre en Android y el reinicio conserva todo.

← [Día 2](dia2.md) · [Índice](../README.md) · Siguiente: [Día 4](dia4.md)

## Mapa del día

| Paso | Qué haces | Archivo | Entrega / depende de |
|---|---|---|---|
| 1 | Pantalla Partida | `lib/presentation/match_page.dart` | **En `main` a las 12:00** (Miguel la espera) |
| 2 | Pestaña Jugar | `lib/presentation/play_page.dart` + 1 línea en `app_shell.dart` | `team_slot` y `team_page` de Emma (jueves) |
| 3 | Plan B | README | **14:00** |
| 4 | Integrar los PR de Miguel y Emma | — | |
| 5 | Android | — | |

**Tiempo:** unas 3,5 h de código (~650 líneas) más Android e integración. [Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

```bash
git switch main && git pull
git switch -c sebastian/dia3-partida
cd app_flutter
```

---

## Paso 1 · Pantalla Partida

Es la versión final, salvo `next()`. Mientras no exista `result_page.dart`, al terminar la partida se vuelve atrás. El comentario `PROVISIONAL` marca el lugar que Miguel cambia hoy.

**Crea** el archivo en 7 partes.

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 1 de 7 (líneas 1–46) · empieza el archivo · **versión provisional**

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/game.dart';
import '../domain/tennis_card.dart';
import 'theme.dart';
import 'widgets/card_back.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/flip_card.dart';
import 'widgets/player_card.dart';

// --- Estado de la ronda ---

/// Una partida: elegir carta → confirmar → se revela la carta rival.
class MatchPage extends StatefulWidget {
  final AppController app;
  final MatchSession match;
  const MatchPage({super.key, required this.app, required this.match});
  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  // Las tres cartas del equipo, en orden fijo (remaining se va vaciando).
  late final List<TennisCard> hand = List.of(widget.match.remaining);
  String? selected; // carta elegida en esta ronda
  RoundResult? current; // resultado de la ronda ya confirmada

  MatchSession get m => widget.match;
  int get round => current == null ? m.results.length : m.results.length - 1;
  Challenge get challenge => Challenge.values[round];

  void confirm() => setState(() => current = m.play(selected!));

  void next() {
    if (m.finished) {
      // PROVISIONAL: el viernes Miguel cambia esto por la pantalla Resultado.
      Navigator.pop(context);
    } else {
      setState(() {
        selected = null;
        current = null;
      });
    }
  }
```

- **Estado de la pantalla:** `hand` (tus 3 cartas, en orden fijo), `selected` (la carta tocada en esta ronda) y `current` (el resultado de la ronda confirmada, o `null` mientras eliges). Lo demás se calcula a partir de `MatchSession` (tu `game.dart`).
- `round` resta 1 cuando hay `current`: después de confirmar, la ronda ya está en `m.results`, pero en pantalla debe seguir mostrándose la misma.
- **Flujo de una ronda:** tocas una carta (`selected`) → `confirm()` llama a `m.play()` y guarda `current` → `next()` limpia todo para la ronda siguiente.

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 2 de 7 (líneas 48–83) · sigue debajo de la parte anterior · **versión provisional**

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _topRow(),
          _scoreboard(),
          const SizedBox(height: 12),
          _challengeBanner(),
          const SizedBox(height: 16),
          _duel(),
          const SizedBox(height: 16),
          _hand(),
          const SizedBox(height: 20),
          current != null
              ? CourtButton(
                  m.finished ? 'Ver resultado' : 'Siguiente ronda',
                  variant: ButtonVariant.accent,
                  size: ButtonSize.lg,
                  iconRight: Icons.chevron_right,
                  full: true,
                  onPressed: next,
                )
              : CourtButton(
                  selected == null ? 'Elige una carta' : 'Confirmar elección',
                  size: ButtonSize.lg,
                  full: true,
                  onPressed: selected == null ? null : confirm,
                ),
        ],
      ),
    ),
  );
```

- El botón de abajo cambia según el momento: «Elige una carta» (deshabilitado) → «Confirmar elección» → «Siguiente ronda» o «Ver resultado».

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 3 de 7 (líneas 85–176) · sigue debajo de la parte anterior · **versión provisional**

```dart
  // --- Ronda y marcador ---

  /// Cerrar (abandonar no suma partidas), ronda actual y tres puntos.
  Widget _topRow() => SizedBox(
    height: 56,
    child: Row(
      children: [
        RoundIconButton(
          icon: Icons.close,
          tooltip: 'Salir de la partida',
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'Ronda ${round + 1} de 3',
            textAlign: TextAlign.center,
            style: display(15, weight: FontWeight.w700),
          ),
        ),
        SizedBox(
          width: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                _dot(i),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  Widget _dot(int i) {
    final outcome = i < m.results.length ? m.results[i].outcome : null;
    final (Color color, Color? border) = switch (outcome) {
      null => (i == round ? Court.c800 : Court.line, null),
      1 => (Court.ball, Court.c800),
      0 => (Colors.white, Court.muted),
      _ => (Court.muted, null),
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border),
      ),
    );
  }

  Widget _scoreboard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Court.line),
    ),
    child: Row(
      children: [
        const Avatar(size: 30),
        const SizedBox(width: 8),
        Text('Tú', style: body(14, weight: FontWeight.w600)),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '${m.playerScore} ',
              children: [
                TextSpan(
                  text: '–',
                  style: TextStyle(color: Court.muted.withValues(alpha: 0.5)),
                ),
                TextSpan(text: ' ${m.opponentScore}'),
              ],
            ),
            textAlign: TextAlign.center,
            style: display(28, height: 1),
          ),
        ),
        Text('CPU', style: body(14, weight: FontWeight.w600)),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 15,
          backgroundColor: Court.ink,
          child: Icon(Icons.memory, size: 17, color: Colors.white),
        ),
      ],
    ),
  );
```

- La X de arriba cierra sin guardar. Abandonar **no** suma una partida jugada.
- Los 3 puntos muestran cada ronda: verde limón si ganaste, blanco si empataste, gris si perdiste.
- El marcador muestra «Tú» contra «CPU».

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 4 de 7 (líneas 178–253) · sigue debajo de la parte anterior · **versión provisional**

```dart
  // --- Atributo de la ronda ---

  Widget _challengeBanner() => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Court.c800,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        const CourtLines(opacity: 0.1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Wrap: si la regla no cabe al lado del atributo, baja a otra línea.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATRIBUTO DE LA RONDA',
                    style: body(
                      11.5,
                      weight: FontWeight.w600,
                      color: Court.ball,
                    ).copyWith(letterSpacing: 0.9),
                  ),
                  Text(
                    challenge.label,
                    style: display(26, color: Colors.white, height: 1.2),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      challenge.lowerWins
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        challenge.rule,
                        style: body(
                          12,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
```

- El banner dice el atributo de la ronda y su regla, con una flecha ↓ (gana el menor) o ↑ (gana el mayor).
- `Wrap`: si «Gana el porcentaje mayor» no cabe al lado de «% de victorias», baja a otra línea en vez de desbordar.

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 5 de 7 (líneas 255–347) · sigue debajo de la parte anterior · **versión provisional**

```dart
  // --- El duelo ---

  /// Tu carta contra la carta oculta de la computadora.
  Widget _duel() {
    TennisCard? mine;
    if (selected != null) mine = hand.firstWhere((c) => c.id == selected);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu carta',
                style: body(12, weight: FontWeight.w600, color: Court.muted),
              ),
              const SizedBox(height: 6),
              Center(
                child: SizedBox(
                  width: 128,
                  child: mine == null
                      ? AspectRatio(
                          aspectRatio: 5 / 7,
                          child: DashedBorder(
                            fill: Court.c50.withValues(alpha: 0.6),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_downward,
                                    size: 18,
                                    color: Court.c700,
                                  ),
                                  Text(
                                    'Elige una carta abajo',
                                    textAlign: TextAlign.center,
                                    style: body(
                                      12,
                                      weight: FontWeight.w600,
                                      color: Court.c700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : _mini(mine),
                ),
              ),
              if (current != null) _valueBox(current!.player, current!.outcome),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Computadora',
                style: body(12, weight: FontWeight.w600, color: Court.muted),
              ),
              const SizedBox(height: 6),
              Center(
                child: SizedBox(
                  width: 128,
                  child: FlipCard(
                    key: ValueKey(round), // ronda nueva = carta boca abajo
                    flipped: current != null,
                    back: const CardBack(label: 'Oculta'),
                    front: current == null
                        ? const SizedBox.shrink()
                        : _mini(current!.opponent),
                  ),
                ),
              ),
              if (current != null)
                _valueBox(current!.opponent, -current!.outcome),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mini(TennisCard card) => PlayerCard(
    card: card,
    number: widget.app.numberOf(card),
    size: CardSize.xs,
  );
```

- A la izquierda, tu carta (o un recuadro «Elige una carta abajo»). A la derecha, la del rival.
- `FlipCard(key: ValueKey(round))`: la `key` cambia en cada ronda, Flutter crea un `FlipCard` nuevo y la carta del rival vuelve a aparecer **boca abajo** sin animarse al revés.

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 6 de 7 (líneas 349–389) · sigue debajo de la parte anterior · **versión provisional**

```dart
  // --- Valor comparado ---

  /// Valor comparado con su resultado: Gana / Empate / Pierde.
  Widget _valueBox(TennisCard card, int outcome) {
    final (
      Color bg,
      Color fg,
      Color border,
      IconData icon,
      String label,
    ) = switch (outcome) {
      1 => (Court.ball, Court.c900, Court.c800, Icons.check, 'Gana'),
      0 => (Colors.white, Court.ink, Court.muted, Icons.drag_handle, 'Empate'),
      _ => (Court.locked, Court.muted, Court.line, Icons.close, 'Pierde'),
    };
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: outcome == -1 ? 1 : 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatStat(card, challenge),
              style: display(24, color: fg, height: 1),
            ),
          ),
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 2),
          Text(
            label,
            style: body(12, weight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
```

- Debajo de cada carta, el valor comparado con «Gana», «Empate» o «Pierde».
- Para el rival se pasa `-current!.outcome`: si tú ganas (1), el rival pierde (-1).

📄 **`app_flutter/lib/presentation/match_page.dart`** · parte 7 de 7 (líneas 391–480) · sigue debajo de la parte anterior · **versión provisional**

```dart
  // --- Tus cartas ---

  /// Tus tres cartas con el valor del atributo de esta ronda.
  Widget _hand() {
    final used = m.results.map((r) => r.player.id).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tus cartas · ${challenge.label}',
                style: body(12, weight: FontWeight.w600, color: Court.muted),
              ),
            ),
            DemoTag(demo: widget.app.isDemo),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < hand.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _handCard(hand[i], used)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _handCard(TennisCard card, Set<String> used) {
    final isSelected = selected == card.id;
    final isUsed = used.contains(card.id) && current?.player.id != card.id;
    final locked = isUsed || current != null;
    final (Color bg, Color fg) = isUsed
        ? (Court.locked, Court.muted)
        : isSelected
        ? (Court.c800, Colors.white)
        : (Colors.white, Court.ink);
    return Opacity(
      opacity: current != null && !isSelected ? 0.6 : 1,
      child: GestureDetector(
        key: ValueKey('mano-${card.id}'), // los tests tocan la carta por su id
        onTap: locked ? null : () => setState(() => selected = card.id),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Court.c900 : Court.line,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.lastName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: display(13, weight: FontWeight.w700, color: fg),
              ),
              Text(
                formatStat(card, challenge),
                style: display(20, color: fg, height: 1.2).copyWith(
                  decoration: isUsed ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                isUsed
                    ? 'Usada'
                    : isSelected
                    ? '✓ Elegida'
                    : 'Disponible',
                style: body(
                  10.5,
                  weight: FontWeight.w600,
                  color: isSelected ? Court.ball : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- Tus 3 cartas muestran el valor del atributo **de esta ronda**, para que elijas bien.
- Una carta usada en rondas anteriores aparece tachada y no se puede tocar.
- `ValueKey('mano-${card.id}')`: la prueba de interfaz del sábado toca cada carta por su id.

```bash
dart format lib && flutter analyze && flutter test
git add -A && git commit -m "Pantalla Partida con volteo de la carta rival"
git push -u origin sebastian/dia3-partida
gh pr create --fill && gh pr merge --squash --delete-branch
```

📣 **Avisa a Miguel: «match_page en main».**

## Paso 2 · Pestaña Jugar (rama `sebastian/dia3-jugar`)

```bash
git switch main && git pull && git switch -c sebastian/dia3-jugar
```

**Crea** el archivo en 2 partes.

📄 **`app_flutter/lib/presentation/play_page.dart`** · parte 1 de 2 (líneas 1–24) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'match_page.dart';
import 'navigation.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/team_slot.dart';

// --- Abrir el equipo o la partida ---

class PlayPage extends StatelessWidget {
  final AppController app;
  const PlayPage({super.key, required this.app});

  void _openTeam(BuildContext context) =>
      openPage(context, app, () => TeamPage(app: app));

  void _start(BuildContext context) {
    // La partida se crea una sola vez, fuera del builder de la pantalla.
    final match = app.startMatch();
    openPage(context, app, () => MatchPage(app: app, match: match));
  }
```

- `_start()` crea la partida **una sola vez, fuera del `builder`**. `openPage` vuelve a ejecutar el builder cada vez que el controlador avisa un cambio. Si `startMatch()` estuviera adentro, cada aviso crearía una partida nueva con otro rival.
- «Cambiar equipo» y los espacios vacíos abren `TeamPage` (de Emma). Al guardar, `TeamPage` vuelve sola a la pestaña Jugar.

📄 **`app_flutter/lib/presentation/play_page.dart`** · parte 2 de 2 (líneas 26–183) · sigue debajo de la parte anterior

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final chosen = app.team.length;
    final missing = 3 - chosen;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const ScreenTitle(
          'Jugar',
          subtitle: 'Partida rápida contra la computadora',
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Court.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cómo se juega',
                style: display(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Tres rondas con un atributo fijo cada una. Elige una carta '
                'por ronda; cada carta se usa una sola vez. Si los valores '
                'son iguales, la ronda queda empatada.',
                style: body(13, color: Court.muted),
              ),
              const SizedBox(height: 12),
              const RulesList(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Tu equipo ',
                        style: display(17, weight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: '· $chosen de 3',
                            style: body(
                              13,
                              weight: FontWeight.w500,
                              color: Court.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CourtButton(
                    'Cambiar equipo',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    icon: Icons.swap_horiz,
                    onPressed: () => _openTeam(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: i < chosen
                          ? TeamSlot(
                              index: i,
                              card: app.selected[i],
                              number: app.numberOf(app.selected[i]),
                            )
                          : TeamSlot(index: i, onTap: () => _openTeam(context)),
                    ),
                  ],
                ],
              ),
              if (missing > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Court.ball.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Court.ballDark.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Court.c900,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: body(13, color: Court.c900),
                            children: [
                              TextSpan(
                                text: missing == 1
                                    ? 'Te falta 1 tenista. '
                                    : 'Te faltan $missing tenistas. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    'Pulsa «Cambiar equipo» o ve a '
                                    'Colección › Elegir equipo y selecciona '
                                    'tres tenistas diferentes.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CourtButton(
            'Iniciar partida',
            variant: ButtonVariant.accent,
            size: ButtonSize.lg,
            icon: Icons.sports_baseball_outlined,
            full: true,
            onPressed: missing == 0 && !app.busy ? () => _start(context) : null,
          ),
        ),
      ],
    );
  }
}
```

- Arriba, «Cómo se juega» con la `RulesList` de Miguel.
- Tu equipo: los espacios llenos muestran la carta y los vacíos se pueden tocar para elegir.
- Con el equipo incompleto aparece «Te faltan N tenistas» y el botón queda deshabilitado. La regla también está en el controlador (`startMatch` lanza `StateError`).

Conecta la pestaña en `app_shell.dart`. Agrega el import (en orden alfabético, con los otros):

```dart
import 'play_page.dart';
```

Y cambia la línea de la pestaña provisional:

```dart
              PlayPage(app: app),   // en lugar de const PantallaPendiente('Jugar', …)
```

Si ya no queda ningún `PantallaPendiente` en el archivo, borra también `import 'pendiente.dart';` y el archivo `lib/presentation/pendiente.dart`.

```bash
dart format lib && flutter analyze && flutter test
flutter run -d linux
```

Jugar → Cambiar equipo → elige 3 → Guardar → Iniciar partida → 3 rondas. El rival nunca es uno de tus tenistas y el banner cambia de atributo en cada ronda. Mientras Miguel no conecte Resultado, al final se vuelve a Jugar.

```bash
git add -A && git commit -m "Pestaña Jugar con el diseño del mockup"
git push -u origin sebastian/dia3-jugar && gh pr create --fill
```

## Paso 3 · Plan B (14:00)

Si a esta hora `/catalog` no entrega al menos 6 cartas reales, presentamos en modo demo y declaramos la limitación (ver el [plan](../../plan-crunch/README.md#plan-b-de-la-api-decisión-el-viernes-23-a-las-1400)). Anota la decisión en el README.

## Paso 4 · Integración del día (en este orden)

1. **Miguel: `profile_page.dart` y `result_page.dart`.** Su PR también cambia `next()` en tu `match_page.dart`. Revisa que el cambio sea **solo** eso, más los imports de `navigation.dart` y `result_page.dart`:

   ```dart
   void next() {
     if (m.finished) {
       openPage(
         context,
         widget.app,
         () => ResultPage(app: widget.app, match: m),
         replace: true,
       );
     } else {
   ```

2. **Emma: `collection_page.dart` y `home_page.dart`.** Su PR reemplaza la pestaña provisional de Colección y el Inicio provisional.
3. Al final, en `app_shell.dart` ya no debe quedar ningún `PantallaPendiente` y `pendiente.dart` debe estar borrado:

   ```bash
   grep -rn PantallaPendiente lib/ || echo "listo"
   ```

## Paso 5 · Android

La lista está en la sección del viernes de [`../../plan-crunch/sebastian.md`](../../plan-crunch/sebastian.md): `adb` en el PATH, emulador, teléfono por USB con `adb reverse tcp:8787 tcp:8787`, y la app debe abrir **sin el servidor** después de la primera carga. Además:

- [ ] El nombre en el teléfono es **SpinTCG** y las **fuentes** se ven (Archivo en títulos y números). Si ves Roboto, ejecuta `flutter clean` y revisa la indentación de `fonts:` en `pubspec.yaml`.
- [ ] Con datos reales, los nombres largos terminan en «…» en Colección, Elegir equipo y Partida.
- [ ] Si llega un código de país que no está en `countries.dart`, pídele a Emma que lo agregue.

**Recorrido completo:** Inicio → Abrir sobre → revelar 3 → Ver colección → Elegir equipo → Guardar → Iniciar partida → 3 rondas → Resultado guardado → Ir al inicio → **cerrar la app** → reabrir: cartas, equipo, apodo y partidas siguen ahí.

## Cierre del día

- [ ] Plan B decidido y anotado.
- [ ] `main` con **todas** las pantallas y sin `pendiente.dart`; `flutter analyze` y `flutter test` en verde.
- [ ] `git grep -n -i "x-rapidapi-key"` solo aparece en `servidor_api/server.mjs` (donde se envía) y en `test/catalog_test.dart` (que comprueba que la app **no** la envía).
- [ ] Check-in de las 21:00.
