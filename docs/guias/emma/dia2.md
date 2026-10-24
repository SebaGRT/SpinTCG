<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Emma · Día 2 (jueves 22): espacios del equipo, Elegir equipo y Detalle

**Meta del día:** las pantallas para armar el equipo. Sebastián necesita `team_slot.dart` y `team_page.dart` en `main` hoy, para la pestaña Jugar del viernes. El Detalle va después.

← [Día 1](dia1.md) · [Índice](../README.md) · Siguiente: [Día 3](dia3.md)

## Mapa del día

| Paso | Qué haces | Archivo | Depende de |
|---|---|---|---|
| 1 | Un espacio del equipo | `lib/presentation/widgets/team_slot.dart` | `common.dart` de Miguel (miércoles) |
| 2 | Elegir equipo | `lib/presentation/team_page.dart` | `navigation.dart` de Sebastián (10:00) · **PR antes de la noche** |
| 3 | Detalle de carta | `lib/presentation/detail_page.dart` | — |
| 4 | Mirar las dos pantallas | `lib/muestra.dart` (no se sube) | Controlador de Sebastián (miércoles) |

**Tiempo:** unas 3,5 h (~610 líneas). [Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

```bash
git switch main && git pull
git switch -c emma/dia2-equipo
cd app_flutter
```

---

## Paso 1 · Un espacio del equipo

**Crea**:

📄 **`app_flutter/lib/presentation/widgets/team_slot.dart`** · 112 líneas

```dart
import 'package:flutter/material.dart';
import '../../domain/tennis_card.dart';
import '../theme.dart';
import 'common.dart';
import 'player_card.dart';

/// Uno de los tres espacios del equipo. Vacío muestra "Espacio N" con borde
/// discontinuo; lleno muestra la carta pequeña con su número.
/// `onRemove` agrega la X para quitar la carta (pantalla Elegir equipo).
class TeamSlot extends StatelessWidget {
  final int index;
  final TennisCard? card;
  final int number;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  const TeamSlot({
    super.key,
    required this.index,
    this.card,
    this.number = 0,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 5 / 7,
          child: DashedBorder(
            fill: Court.c50.withValues(alpha: 0.6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Court.c200),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Court.c700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Espacio ${index + 1}',
                  style: body(11, weight: FontWeight.w600, color: Court.c700),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onRemove ?? onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PlayerCard(card: card!, number: number, size: CardSize.xs),
          Positioned(
            left: -4,
            top: -4,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Court.c800,
                shape: BoxShape.circle,
                border: Border.all(color: Court.paper, width: 2),
              ),
              child: Text(
                '${index + 1}',
                style: display(
                  11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              right: -4,
              top: -4,
              child: Semantics(
                button: true,
                label: 'Quitar a ${card!.lastName}',
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Court.line),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 13, color: Court.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- Si está **vacío**, muestra «Espacio N» con borde discontinuo (`DashedBorder`, de Miguel). Si está **lleno**, muestra la carta xs con su número en un círculo.
- `onRemove` es opcional: si se entrega, aparece la X para quitar la carta (solo en Elegir equipo). En Inicio y Jugar no se pasa.
- `Semantics(label: 'Quitar a …')` en la X: TalkBack dice qué hace el botón, y no solo «botón».
- `clipBehavior: Clip.none` deja que el número y la X sobresalgan del borde de la carta, como en el mockup.

## Paso 2 · Elegir equipo

**Crea** el archivo en 3 partes.

📄 **`app_flutter/lib/presentation/team_page.dart`** · parte 1 de 3 (líneas 1–45) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/countries.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';
import 'widgets/team_slot.dart';

// --- El borrador ---

/// Elegir equipo: se arma un borrador y se guarda al final.
class TeamPage extends StatefulWidget {
  final AppController app;
  const TeamPage({super.key, required this.app});
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final List<String> draft = List.of(widget.app.team);

  void toggle(String id) => setState(() {
    if (draft.contains(id)) {
      draft.remove(id);
    } else if (draft.length < 3) {
      draft.add(id);
    }
  });

  Future<void> save() async {
    try {
      await widget.app.saveTeam(draft);
      if (mounted) goToTab(context, Tabs.play);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }
```

- La pantalla trabaja sobre un **borrador** (`draft`), una copia del equipo actual. Tocar una fila solo cambia el borrador. Recién «Guardar equipo» llama a `app.saveTeam(draft)`. Si sales con ←, no cambia nada.
- `late final draft = List.of(widget.app.team)`: `late` crea la copia la primera vez que se usa, cuando `widget` ya existe.
- Al guardar, `goToTab(context, Tabs.play)` cierra esta pantalla y muestra la pestaña Jugar. Hasta el viernes, esa pestaña dice «En construcción».
- Si `saveTeam` falla, `mensajeDeError(e)` (de Miguel) muestra un mensaje limpio en un SnackBar.

📄 **`app_flutter/lib/presentation/team_page.dart`** · parte 2 de 3 (líneas 47–146) · sigue debajo de la parte anterior

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final owned = app.owned..sort((a, b) => a.ranking.compareTo(b.ranking));
    TennisCard byId(String id) => app.catalog.firstWhere((c) => c.id == id);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            TopBar('Elegir equipo', onBack: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: i < draft.length
                              ? TeamSlot(
                                  index: i,
                                  card: byId(draft[i]),
                                  number: app.numberOf(byId(draft[i])),
                                  onRemove: () => toggle(draft[i]),
                                )
                              : TeamSlot(index: i),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${draft.length} de 3 seleccionadas',
                          style: display(15, weight: FontWeight.w700),
                        ),
                      ),
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 24,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: i < draft.length ? Court.c800 : Court.line,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige tres tenistas diferentes. Las copias repetidas '
                    'cuentan como un solo tenista.',
                    style: body(12.5, color: Court.muted),
                  ),
                  const SizedBox(height: 16),
                  for (final card in owned) _row(card),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Court.paper,
          border: Border(top: BorderSide(color: Court.line)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CourtButton(
              'Guardar equipo',
              size: ButtonSize.lg,
              icon: Icons.check,
              full: true,
              onPressed: draft.length == 3 && !app.busy ? save : null,
            ),
            if (draft.length < 3) ...[
              const SizedBox(height: 6),
              Text(
                'Selecciona ${3 - draft.length} más para guardar',
                style: body(12, color: Court.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
```

- Arriba van los 3 espacios (con X para quitar), el contador «N de 3 seleccionadas» y las barritas de progreso.
- La lista muestra solo cartas **obtenidas**, ordenadas por ranking.
- El botón queda **fijo abajo** porque va en `Scaffold.bottomNavigationBar`, fuera de la lista que se desplaza.

📄 **`app_flutter/lib/presentation/team_page.dart`** · parte 3 de 3 (líneas 148–252) · sigue debajo de la parte anterior

```dart
  // --- Fila de un tenista ---

  /// Fila de un tenista obtenido: mini carta, datos y estado.
  Widget _row(TennisCard card) {
    final app = widget.app;
    final position = draft.indexOf(card.id);
    final selected = position >= 0;
    final blocked = !selected && draft.length == 3;
    final copies = app.copies[card.id] ?? 0;

    return Opacity(
      opacity: blocked ? 0.45 : 1,
      child: GestureDetector(
        onTap: blocked ? null : () => toggle(card.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: selected ? Court.c50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Court.c700 : Court.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: PlayerCard(
                  card: card,
                  number: app.numberOf(card),
                  size: CardSize.xs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: display(15, weight: FontWeight.w700),
                    ),
                    Text(
                      countryName(card.country) +
                          (copies > 1 ? ' · ×$copies copias' : ''),
                      style: body(12, color: Court.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatStat(card, Challenge.ranking)}   '
                      '${card.titles} títulos   '
                      '${formatStat(card, Challenge.winRate)}',
                      style: body(
                        12,
                        weight: FontWeight.w600,
                        color: Court.c800,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Court.c800,
                      child: Icon(Icons.check, size: 17, color: Court.ball),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Espacio ${position + 1}',
                      style: body(
                        10.5,
                        weight: FontWeight.w700,
                        color: Court.c800,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Court.line, width: 2),
                  ),
                  child: Icon(
                    blocked ? Icons.lock_outline : Icons.add,
                    size: blocked ? 14 : 16,
                    color: Court.muted,
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

- `position` es el lugar en el borrador (-1 si no está elegido).
- `blocked`: con 3 elegidos, las demás filas se ven al 45 % y no responden (`onTap: null`).
- La fila elegida se pinta verde claro y muestra «Espacio N»; las otras, un círculo con «+» (o un candado si están bloqueadas).

```bash
dart format lib && flutter analyze && flutter test
git add -A && git commit -m "Espacios del equipo y pantalla Elegir equipo"
git push -u origin emma/dia2-equipo && gh pr create --fill
```

📣 Avisa a Sebastián: «team_slot y team_page en PR». Él los usa en la pestaña Jugar.

## Paso 3 · Detalle de carta (rama nueva)

```bash
git switch -c emma/dia2-detalle
```

**Crea** el archivo en 5 partes.

📄 **`app_flutter/lib/presentation/detail_page.dart`** · parte 1 de 5 (líneas 1–31) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'navigation.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/countries.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';

// --- Añadir o quitar del equipo ---

class DetailPage extends StatelessWidget {
  final AppController app;
  final TennisCard card;
  const DetailPage({super.key, required this.app, required this.card});

  /// Añade la carta al equipo o la quita. Un error se muestra en un SnackBar.
  Future<void> _toggle(BuildContext context) async {
    try {
      await app.toggleTeam(card.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }
```

- `DetailPage` es `StatelessWidget`: todo lo que muestra sale del controlador. Como se abre con `openPage` (envuelta en `ListenableBuilder`), al tocar «Añadir al equipo» se redibuja sola.
- `context.mounted`: después de un `await`, la pantalla pudo cerrarse; solo se muestra el SnackBar si sigue abierta.

📄 **`app_flutter/lib/presentation/detail_page.dart`** · parte 2 de 5 (líneas 33–81) · sigue debajo de la parte anterior

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final number = app.numberOf(card);
    final copies = app.copies[card.id] ?? 0;
    final slot = app.team.indexOf(card.id); // -1 si no está en el equipo
    final inTeam = slot >= 0;
    final teamFull = app.team.length == 3;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            TopBar(
              'Detalle de carta',
              onBack: () => Navigator.pop(context),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'N.º ${number.toString().padLeft(2, '0')}/${app.catalog.length}',
                  style: body(13, weight: FontWeight.w600, color: Court.muted),
                ),
              ),
            ),
            _bigCard(number, copies, inTeam),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _names(),
                  const SizedBox(height: 16),
                  _stats(),
                  const SizedBox(height: 12),
                  _copiesRow(copies),
                  const SizedBox(height: 12),
                  DemoTag(demo: app.isDemo),
                  const SizedBox(height: 20),
                  ..._actions(context, inTeam, slot, teamFull),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
```

- `build` solo arma la estructura y delega cada bloque a un método (`_bigCard`, `_names`, `_stats`…). Así cada pieza se lee por separado.
- El encabezado dice «N.º 08/24»: `padLeft(2, '0')` convierte 8 en `08`.
- `..._actions(...)` agrega **varios** widgets a la lista (los `...` «desarman» la lista que devuelve el método).

📄 **`app_flutter/lib/presentation/detail_page.dart`** · parte 3 de 5 (líneas 83–146) · sigue debajo de la parte anterior

```dart
  // --- La carta grande y el nombre ---

  /// La carta en tamaño grande, sobre un recuadro verde claro.
  Widget _bigCard(int number, int copies, bool inTeam) => Container(
    margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
    padding: const EdgeInsets.symmetric(vertical: 24),
    decoration: BoxDecoration(
      color: Court.c50,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Center(
      child: SizedBox(
        width: 230,
        child: PlayerCard(
          card: card,
          number: number,
          total: app.catalog.length,
          copies: copies,
          size: CardSize.lg,
          inTeam: inTeam,
        ),
      ),
    ),
  );

  /// Nombre, apellido grande y las píldoras de país y circuito.
  Widget _names() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        card.firstName,
        style: body(14, weight: FontWeight.w500, color: Court.muted),
      ),
      Text(card.lastName, style: display(30, height: 1)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _pill(
            '${card.country} · ${countryName(card.country)}',
            Colors.white,
            Court.ink,
            border: true,
          ),
          _pill('Circuito ATP', Court.c800, Court.ball),
        ],
      ),
    ],
  );

  Widget _pill(String text, Color bg, Color fg, {bool border = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
          border: border ? Border.all(color: Court.line) : null,
        ),
        child: Text(
          text,
          style: body(12.5, weight: FontWeight.w600, color: fg),
        ),
      );
```

- La carta grande es tu `PlayerCard` en tamaño `lg`, sobre un recuadro verde claro.
- `_pill()` es una píldora reutilizable: con borde (país) o rellena (circuito).

📄 **`app_flutter/lib/presentation/detail_page.dart`** · parte 4 de 5 (líneas 148–200) · sigue debajo de la parte anterior

```dart
  // --- Estadísticas y copias ---

  /// Las tres estadísticas. Ranking va destacada en verde.
  Widget _stats() => Row(
    children: [
      Expanded(
        child: StatBox(
          label: 'Ranking',
          value: formatStat(card, Challenge.ranking),
          hint: 'menor es mejor',
          emphasis: true,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: StatBox(
          label: 'Títulos',
          value: formatStat(card, Challenge.titles),
          hint: 'mayor es mejor',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: StatBox(
          label: '% victorias',
          value: formatStat(card, Challenge.winRate),
          hint: 'mayor es mejor',
        ),
      ),
    ],
  );

  Widget _copiesRow(int copies) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Court.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.copy_rounded, size: 18, color: Court.c700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Copias en tu colección',
            style: body(14, weight: FontWeight.w600),
          ),
        ),
        Text('×$copies', style: display(20)),
      ],
    ),
  );
```

- Las tres cajas usan `StatBox` (de Miguel). Ranking va destacada en verde, y cada una dice si «menor/mayor es mejor».
- `DemoTag` (en el `build`) aclara si los datos son de demostración o de RapidAPI. Es un requisito: **nunca presentar datos demo como reales**.

📄 **`app_flutter/lib/presentation/detail_page.dart`** · parte 5 de 5 (líneas 202–271) · sigue debajo de la parte anterior

```dart
  // --- Botones del equipo ---

  /// Tres casos: ya está en el equipo, hay espacio, o el equipo está lleno.
  List<Widget> _actions(
    BuildContext context,
    bool inTeam,
    int slot,
    bool teamFull,
  ) {
    if (inTeam) {
      return [
        CourtButton(
          'Quitar del equipo',
          variant: ButtonVariant.secondary,
          size: ButtonSize.lg,
          icon: Icons.remove,
          full: true,
          onPressed: app.busy ? null : () => _toggle(context),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '✓ En tu equipo · Espacio ${slot + 1}',
            style: body(12.5, color: Court.muted),
          ),
        ),
      ];
    }
    if (!teamFull) {
      return [
        CourtButton(
          'Añadir al equipo',
          size: ButtonSize.lg,
          icon: Icons.add,
          full: true,
          onPressed: app.busy ? null : () => _toggle(context),
        ),
      ];
    }
    return [
      const CourtButton(
        'Añadir al equipo',
        size: ButtonSize.lg,
        icon: Icons.add,
        full: true,
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tu equipo está completo.',
            style: body(12.5, color: Court.muted),
          ),
          TextButton(
            onPressed: () => openPage(context, app, () => TeamPage(app: app)),
            child: Text(
              'Editar equipo',
              style: body(
                12.5,
                weight: FontWeight.w600,
                color: Court.c700,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    ];
  }
}
```

- Tres casos, en orden: ya está en el equipo → «Quitar del equipo»; hay espacio → «Añadir al equipo»; equipo lleno → botón deshabilitado y el enlace «Editar equipo» hacia `TeamPage`.
- `app.busy ? null : …` deshabilita el botón mientras se guarda.

## Paso 4 · Mirar las dos pantallas

Todavía no se llega a estas pantallas desde la app (Colección llega mañana). Reemplaza tu `lib/muestra.dart`:

📄 **`app_flutter/lib/muestra.dart`** · 50 líneas · **versión provisional**

```dart
// Abre Elegir equipo y Detalle con datos demo, sin tocar la app.
// Ejecutar: flutter run -t lib/muestra.dart   (NO se sube al repo)
import 'package:flutter/material.dart';
import 'application/app_controller.dart';
import 'data/catalog_repository.dart';
import 'data/local_store.dart';
import 'presentation/detail_page.dart';
import 'presentation/navigation.dart';
import 'presentation/team_page.dart';
import 'presentation/theme.dart';
import 'presentation/widgets/court_button.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catálogo demo y progreso en memoria: se pierde al cerrar.
  final app = AppController(CatalogRepository(''), MemoryLocalStore());
  await app.load();
  final tab = ValueNotifier(Tabs.home);
  runApp(
    MaterialApp(
      theme: buildTheme(),
      builder: (context, child) => TabScope(tab: tab, child: child!),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CourtButton(
                  'Elegir equipo',
                  onPressed: () =>
                      openPage(context, app, () => TeamPage(app: app)),
                ),
                const SizedBox(height: 12),
                CourtButton(
                  'Detalle de una carta',
                  onPressed: () => openPage(
                    context,
                    app,
                    () => DetailPage(app: app, card: app.owned.first),
                  ),
                ),
              ],
            ),
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

- Elegir equipo: elige 3 → las demás filas se bloquean → quita una con la X → vuelve a elegir → Guardar. (En la muestra no hay pestañas: solo se cierra la pantalla).
- Detalle: Añadir → cambia a «Quitar del equipo» y aparece «✓ En tu equipo · Espacio N».

```bash
dart format lib && flutter analyze && flutter test
git add lib/presentation && git commit -m "Pantalla Detalle de carta"
git push -u origin emma/dia2-detalle && gh pr create --fill
```

## Cierre del día

- [ ] Dos PR: equipo y Detalle.
- [ ] Sabes explicar por qué Elegir equipo usa un borrador y Detalle no.
- [ ] Check-in de las 21:00.
