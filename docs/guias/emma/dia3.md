<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Emma · Día 3 (viernes 23): Colección e Inicio

**Meta del día:** las dos pantallas que más se ven. Con esto, **toda** la app queda con el diseño del mockup y ya no quedan pestañas «En construcción».

← [Día 2](dia2.md) · [Índice](../README.md) · Siguiente: [Día 4](dia4.md)

## Mapa del día

| Paso | Qué haces | Archivo | Depende de |
|---|---|---|---|
| 1 | Colección | `lib/presentation/collection_page.dart` | — |
| 2 | Conectar la pestaña Colección | `lib/presentation/app_shell.dart` (1 línea + import) | — |
| 3 | Inicio | `lib/presentation/home_page.dart` (reemplaza el provisional) | `pack_art.dart` (Miguel, jueves) y `profile_page.dart` (Miguel, hoy 12:00) |

**Tiempo:** unas 3 h (~560 líneas). [Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

```bash
git switch main && git pull
git switch -c emma/dia3-coleccion-inicio
cd app_flutter
```

---

## Paso 1 · Colección

**Crea** el archivo en 4 partes.

📄 **`app_flutter/lib/presentation/collection_page.dart`** · parte 1 de 4 (líneas 1–24) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'detail_page.dart';
import 'navigation.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';

// --- Buscar sin tildes ---

/// Quita tildes y pasa a minúsculas: "Cerúndolo" → "cerundolo".
String normalize(String text) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñçš';
  const to = 'aaaaeeeeiiiioooouuuuncs';
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final char in lower.split('')) {
    final i = from.indexOf(char);
    out.write(i == -1 ? char : to[i]);
  }
  return out.toString();
}
```

- `normalize()` quita tildes y pasa a minúsculas: buscar «cerundolo» encuentra a *Cerúndolo*.
- Recorre el texto letra por letra: si la letra está en `from`, la cambia por la del mismo lugar en `to`.

📄 **`app_flutter/lib/presentation/collection_page.dart`** · parte 2 de 4 (líneas 26–119) · sigue debajo de la parte anterior

```dart
// --- Estado y filtro ---

class CollectionPage extends StatefulWidget {
  final AppController app;
  const CollectionPage({super.key, required this.app});
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final search = TextEditingController();
  bool duplicatesOnly = false;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final query = normalize(search.text.trim());
    final duplicateCount = app.copies.values.where((n) => n > 1).length;
    final cards = app.catalog.where((card) {
      final copies = app.copies[card.id] ?? 0;
      if (duplicatesOnly && copies < 2) return false;
      // Al buscar, solo aparecen cartas obtenidas (las demás son secretas).
      if (query.isNotEmpty) {
        return copies > 0 && normalize(card.name).contains(query);
      }
      return true;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenTitle(
            'Colección',
            subtitle:
                '${app.uniqueCount} de ${app.catalog.length} cartas únicas',
            trailing: CourtButton(
              'Elegir equipo',
              size: ButtonSize.sm,
              icon: Icons.swap_horiz,
              onPressed: () => openPage(context, app, () => TeamPage(app: app)),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                _searchField(),
                const SizedBox(height: 12),
                _segmented(app.catalog.length, duplicateCount),
              ],
            ),
          ),
        ),
        if (cards.isEmpty)
          SliverToBoxAdapter(child: _empty(query.isNotEmpty))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 5 / 7,
              children: [
                for (final card in cards)
                  PlayerCard(
                    card: card,
                    number: app.numberOf(card),
                    total: app.catalog.length,
                    copies: app.copies[card.id] ?? 0,
                    locked: (app.copies[card.id] ?? 0) == 0,
                    inTeam: app.team.contains(card.id),
                    onTap: (app.copies[card.id] ?? 0) == 0
                        ? null
                        : () => openPage(
                            context,
                            app,
                            () => DetailPage(app: app, card: card),
                          ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
```

- Estado de la pantalla: el texto del buscador (`search`) y si el filtro Duplicadas está activo.
- `dispose()` libera el `TextEditingController`: todo controlador de texto se libera.
- **Al buscar, solo aparecen cartas obtenidas.** Las demás son secretas: no se puede buscar a un tenista que no tienes.
- `CustomScrollView` con *slivers*: el título, el buscador y el filtro se desplazan junto con la grilla (`SliverGrid`), en vez de quedar fijos encima.
- `SliverGrid` de 2 columnas con `childAspectRatio: 5 / 7`, la misma proporción de la carta. Las bloqueadas no responden; las obtenidas abren el Detalle con `openPage`.

📄 **`app_flutter/lib/presentation/collection_page.dart`** · parte 3 de 4 (líneas 121–200) · sigue debajo de la parte anterior

```dart
  // --- Buscador y filtro ---

  Widget _searchField() => TextField(
    controller: search,
    onChanged: (_) => setState(() {}),
    style: body(15),
    decoration: InputDecoration(
      hintText: 'Buscar por nombre',
      hintStyle: body(15, color: Court.disabledText),
      prefixIcon: const Icon(Icons.search, color: Court.muted),
      suffixIcon: search.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Borrar búsqueda',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(search.clear),
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Court.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Court.c600, width: 2),
      ),
    ),
  );

  /// Selector Todas / Duplicadas.
  Widget _segmented(int total, int duplicates) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Court.segment,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        _segment('Todas', total, !duplicatesOnly, false),
        _segment('Duplicadas', duplicates, duplicatesOnly, true),
      ],
    ),
  );

  Widget _segment(String label, int count, bool active, bool value) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => duplicatesOnly = value),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? const [BoxShadow(color: Colors.black12, blurRadius: 2)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (active) ...[
              const Icon(Icons.check, size: 15, color: Court.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: body(
                14,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Court.ink : Court.muted,
              ),
            ),
            const SizedBox(width: 6),
            Text('$count', style: body(14, color: Court.muted)),
          ],
        ),
      ),
    ),
  );
```

- El buscador muestra una X para borrar solo cuando hay texto escrito.
- El selector Todas/Duplicadas son dos `_segment` dentro de un fondo gris. Cada uno muestra su conteo.

📄 **`app_flutter/lib/presentation/collection_page.dart`** · parte 4 de 4 (líneas 202–241) · sigue debajo de la parte anterior

```dart
  // --- Sin resultados ---

  Widget _empty(bool searching) {
    final noDuplicates = duplicatesOnly && !searching;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: DashedBorder(
        radius: 24,
        color: Court.line,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Icon(
                noDuplicates ? Icons.copy_rounded : Icons.search,
                size: 26,
                color: Court.muted,
              ),
              const SizedBox(height: 12),
              Text(
                noDuplicates
                    ? 'Aún no tienes cartas duplicadas'
                    : 'Sin resultados',
                style: display(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                noDuplicates
                    ? 'Abre tu sobre diario para conseguir copias.'
                    : 'No tienes cartas que coincidan con «${search.text}».',
                textAlign: TextAlign.center,
                style: body(13, color: Court.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- Dos estados vacíos, cada uno con su explicación: «Aún no tienes cartas duplicadas» y «Sin resultados».

## Paso 2 · Conectar la pestaña Colección

En `lib/presentation/app_shell.dart` (de Sebastián), agrega el import (en orden alfabético, con los otros):

```dart
import 'collection_page.dart';
```

Y cambia la línea de la pestaña provisional:

```dart
              CollectionPage(app: app),   // en lugar de const PantallaPendiente('Colección', …)
```

Si ya no queda ningún `PantallaPendiente` en el archivo, borra también `import 'pendiente.dart';` y el archivo `lib/presentation/pendiente.dart`.

```bash
dart format lib && flutter analyze && flutter test
flutter run -d linux       # pestaña Colección: busca «MUSETTI», «cerundolo» y prueba Duplicadas
git add -A && git commit -m "Colección con buscador, filtro de duplicadas y grilla de cartas"
```

## Paso 3 · Inicio

**Reemplaza todo** `lib/presentation/home_page.dart` (el Inicio provisional de Sebastián desaparece). Va en 5 partes.

📄 **`app_flutter/lib/presentation/home_page.dart`** · parte 1 de 5 (líneas 1–50) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'app_shell.dart';
import 'navigation.dart';
import 'profile_page.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/pack_art.dart';
import 'widgets/team_slot.dart';

// --- La pantalla ---

class HomePage extends StatelessWidget {
  final AppController app;
  const HomePage({super.key, required this.app});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    children: [
      _header(context),
      const SizedBox(height: 20),
      Text('Hola, ${app.nickname}', style: body(14, color: Court.muted)),
      const SizedBox(height: 2),
      Text(
        app.canOpenPack
            ? 'Tu sobre diario te espera'
            : '¿Listo para la próxima partida?',
        style: display(28, height: 1.05),
      ),
      const SizedBox(height: 20),
      _collectionCard(context),
      const SizedBox(height: 20),
      CourtButton(
        'Jugar partida',
        variant: ButtonVariant.accent,
        size: ButtonSize.lg,
        icon: Icons.sports_baseball_outlined,
        full: true,
        onPressed: () => goToTab(context, Tabs.play),
      ),
      const SizedBox(height: 20),
      _packCard(context),
      const SizedBox(height: 20),
      _teamSection(context),
    ],
  );
```

- El título cambia según el día: «Tu sobre diario te espera» si el sobre está sin abrir y «¿Listo para la próxima partida?» si ya se abrió.
- `build` arma la lista y delega cada bloque a un método.

📄 **`app_flutter/lib/presentation/home_page.dart`** · parte 2 de 5 (líneas 52–71) · sigue debajo de la parte anterior

```dart
  // --- Encabezado ---

  Widget _header(BuildContext context) => Row(
    children: [
      const BrandLogo(),
      const SizedBox(width: 8),
      Expanded(child: Text(kBrand, style: display(19))),
      Tooltip(
        message: 'Perfil',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => openPage(context, app, () => ProfilePage(app: app)),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Avatar(size: 42),
          ),
        ),
      ),
    ],
  );
```

- `BrandLogo` viene de `app_shell.dart`: Inicio y la cáscara se importan entre sí, y Dart lo permite.
- El avatar abre el Perfil (de Miguel) y tiene `Tooltip('Perfil')`. La prueba de interfaz lo busca así.

📄 **`app_flutter/lib/presentation/home_page.dart`** · parte 3 de 5 (líneas 73–173) · sigue debajo de la parte anterior

```dart
  // --- Tarjeta de colección ---

  Widget _collectionCard(BuildContext context) {
    final total = app.catalog.length;
    return GestureDetector(
      onTap: () => goToTab(context, Tabs.collection),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Court.c800,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            const CourtLines(opacity: 0.1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu colección',
                              style: body(
                                13,
                                weight: FontWeight.w600,
                                color: Court.ball,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                text: '${app.uniqueCount}',
                                style: display(
                                  40,
                                  color: Colors.white,
                                  height: 1,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' / $total',
                                    style: display(
                                      22,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'cartas únicas obtenidas',
                              style: body(
                                13,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Ver',
                        style: body(
                          13,
                          weight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : app.uniqueCount / total,
                      minHeight: 8,
                      color: Court.ball,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
```

- La tarjeta verde es un `Container` con `clipBehavior: Clip.antiAlias`, para que las líneas de cancha no se salgan del borde redondeado.
- Al tocarla se va a Colección con `goToTab` (cambia de pestaña; no abre una pantalla nueva).
- La barra de progreso es un `LinearProgressIndicator` dentro de un `ClipRRect`, que le da las puntas redondas. Si el catálogo está vacío, el valor queda en 0 para no dividir por cero.

📄 **`app_flutter/lib/presentation/home_page.dart`** · parte 4 de 5 (líneas 175–236) · sigue debajo de la parte anterior

```dart
  // --- Sobre diario ---

  Widget _packCard(BuildContext context) {
    final opened = !app.canOpenPack;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Court.line),
      ),
      child: Row(
        children: [
          PackArt(width: 58, opened: opened),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu sobre diario',
                  style: display(16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  opened
                      ? 'Abierto hoy · Disponible mañana'
                      : '3 cartas aleatorias, gratis cada día',
                  style: body(13, color: Court.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (opened)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Court.c50,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 14, color: Court.c700),
                  const SizedBox(width: 4),
                  Text(
                    'Abierto',
                    style: body(12, weight: FontWeight.w600, color: Court.c700),
                  ),
                ],
              ),
            )
          else
            CourtButton(
              'Abrir sobre',
              size: ButtonSize.sm,
              onPressed: () => goToTab(context, Tabs.packs),
            ),
        ],
      ),
    );
  }
```

- El sobre usa el `PackArt` de Miguel en tamaño chico.
- Sin abrir: botón «Abrir sobre» (lleva a la pestaña Sobres). Abierto: la etiqueta «Abierto» y el texto «Abierto hoy · Disponible mañana».

📄 **`app_flutter/lib/presentation/home_page.dart`** · parte 5 de 5 (líneas 238–340) · sigue debajo de la parte anterior

```dart
  // --- Tu equipo ---

  Widget _teamSection(BuildContext context) {
    final full = app.team.length == 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tu equipo',
                style: display(17, weight: FontWeight.w700),
              ),
            ),
            if (full)
              TextButton(
                onPressed: () =>
                    openPage(context, app, () => TeamPage(app: app)),
                child: Text(
                  'Editar',
                  style: body(13, weight: FontWeight.w600, color: Court.c700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (full)
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: TeamSlot(
                    index: i,
                    card: app.selected[i],
                    number: app.numberOf(app.selected[i]),
                  ),
                ),
              ],
            ],
          )
        else
          DashedBorder(
            radius: 24,
            fill: Court.c50.withValues(alpha: 0.6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Court.c200),
                        ),
                        child: const Icon(
                          Icons.style_outlined,
                          size: 20,
                          color: Court.c700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elige tu equipo',
                              style: display(16, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Selecciona tres tenistas diferentes para poder '
                              'jugar. ${app.team.length} de 3 elegidos.',
                              style: body(13, color: Court.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CourtButton(
                    'Ir a Colección',
                    variant: ButtonVariant.secondary,
                    iconRight: Icons.chevron_right,
                    full: true,
                    onPressed: () => goToTab(context, Tabs.collection),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

- Con 3 cartas muestra los `TeamSlot` y «Editar» (abre Elegir equipo). Si no, el estado vacío con «Ir a Colección», que cambia de pestaña.

```bash
dart format lib && flutter analyze && flutter test
flutter run -d linux
```

Recorrido completo: Inicio → Abrir sobre → revelar → Ver colección → Elegir equipo → Guardar → Inicio muestra el equipo y el título cambió a «¿Listo para la próxima partida?».

```bash
git add -A && git commit -m "Inicio del mockup"
git push -u origin emma/dia3-coleccion-inicio && gh pr create --fill
```

📣 Avisa a Sebastián: «Colección e Inicio en PR».

## Cierre del día

- [ ] PR con Colección e Inicio.
- [ ] Sabes explicar `normalize()`, los *slivers* y por qué Inicio usa `goToTab` en vez de `Navigator.push`.
- [ ] Check-in de las 21:00.
