<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Sebastián · Día 2 (jueves 22): navegación, cáscara, servidor y API real

**Meta del día:**
- **Antes de las 10:00:** `navigation.dart` en `main`. Emma (Elegir equipo) y Miguel (Sobres) lo usan hoy.
- **Mañana:** la app completa arranca con la barra inferior del mockup. Las pestañas que aún no existen muestran «En construcción».
- **Tarde:** la primera prueba automática, el servidor intermediario escrito a mano y las consultas reales a RapidAPI.

← [Día 1](dia1.md) · [Índice](../README.md) · Siguiente: [Día 3](dia3.md)

## Mapa del día

| Paso | Qué haces | Archivo | Entrega |
|---|---|---|---|
| 1 | Navegación entre pestañas | `lib/presentation/navigation.dart` | **En `main` a las 10:00** |
| 2 | Pestañas «En construcción» | `lib/presentation/pendiente.dart` (provisional) | |
| 2 | La cáscara con la barra inferior | `lib/presentation/app_shell.dart` | |
| 2 | Inicio provisional | `lib/presentation/home_page.dart` (provisional) | |
| 2 | `main.dart` definitivo | `lib/main.dart` | |
| 3 | Primera prueba automática | `test/catalog_test.dart` | PR de la cáscara |
| 4–7 | Servidor intermediario | `servidor_api/.gitignore`, `adapter.mjs`, `server.mjs`, `adapter.test.mjs` | PR del servidor |
| 8 | Consultas reales a RapidAPI | `servidor_api/fixtures/` | |

**Tiempo:** unas 4 h de código (~550 líneas) más la API. [Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

```bash
git switch main && git pull
git switch -c sebastian/dia2-navegacion
cd app_flutter
```

---

## Paso 1 · Navegación entre pestañas (súbelo primero)

📄 **`app_flutter/lib/presentation/navigation.dart`** · 45 líneas

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';

/// Índices de las cuatro pestañas de la barra inferior.
abstract final class Tabs {
  static const home = 0;
  static const collection = 1;
  static const packs = 2;
  static const play = 3;
}

/// Comparte la pestaña activa con las pantallas secundarias (Detalle,
/// Partida, Resultado...), que se abren encima de AppShell.
class TabScope extends InheritedNotifier<ValueNotifier<int>> {
  const TabScope({
    super.key,
    required ValueNotifier<int> tab,
    required super.child,
  }) : super(notifier: tab);

  static ValueNotifier<int> of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TabScope>()!.notifier!;
}

/// Cierra las pantallas secundarias y muestra una pestaña.
void goToTab(BuildContext context, int tab) {
  TabScope.of(context).value = tab;
  Navigator.of(context).popUntil((route) => route.isFirst);
}

/// Abre una pantalla secundaria que se redibuja cuando cambia el controlador.
/// `replace: true` reemplaza la pantalla actual (Partida → Resultado).
Future<void> openPage(
  BuildContext context,
  AppController app,
  Widget Function() page, {
  bool replace = false,
}) {
  final route = MaterialPageRoute<void>(
    builder: (_) =>
        ListenableBuilder(listenable: app, builder: (_, _) => page()),
  );
  final navigator = Navigator.of(context);
  return replace ? navigator.pushReplacement(route) : navigator.push(route);
}
```

**Entiende**
- La pestaña activa es un `ValueNotifier<int>`. `TabScope` (un `InheritedNotifier`) la comparte con **todas** las pantallas, incluidas las secundarias (Detalle, Partida, Resultado) que se abren encima con `Navigator.push`.
- `goToTab(context, Tabs.collection)` cambia la pestaña y cierra las pantallas secundarias (`popUntil(isFirst)`). Así funcionan «Ver colección» después de abrir un sobre o «Ir al inicio» desde Resultado.
- `openPage()` envuelve la pantalla en un `ListenableBuilder` del controlador. Una ruta nueva **no** queda dentro del `ListenableBuilder` de la cáscara, así que sin esto no se redibujaría al cambiar los datos.
- `TabScope.of()` usa `getInheritedWidgetOfExactType`, que lee el valor **sin suscribirse**. Solo la cáscara necesita redibujarse cuando cambia la pestaña.

```bash
dart format lib && flutter analyze
git add -A && git commit -m "Navegación entre pestañas con TabScope"
git push -u origin sebastian/dia2-navegacion
gh pr create --fill && gh pr merge --squash --delete-branch
```

📣 **Avisa: «navigation.dart en main».**

## Paso 2 · La cáscara de la app (rama `sebastian/dia2-cascara`)

```bash
git switch main && git pull && git switch -c sebastian/dia2-cascara
```

Mientras las pantallas no existan, cada pestaña muestra un aviso. Crea este archivo **provisional**:

📄 **`app_flutter/lib/presentation/pendiente.dart`** · 22 líneas · **versión provisional**

```dart
import 'package:flutter/material.dart';
import 'theme.dart';

/// PROVISIONAL: ocupa una pestaña mientras su pantalla no existe.
/// Sebastián borra este archivo cuando las cuatro pestañas estén listas.
class PantallaPendiente extends StatelessWidget {
  final String title;
  final String owner;
  const PantallaPendiente(this.title, {super.key, required this.owner});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: display(28)),
        const SizedBox(height: 8),
        Text('En construcción · $owner', style: body(14, color: Court.muted)),
      ],
    ),
  );
}
```

Ahora la cáscara. Es la versión final, salvo las tres pestañas marcadas con `PantallaPendiente`. Cada dueño cambia su línea cuando su pantalla esté lista: Miguel (Sobres, hoy), tú (Jugar, viernes) y Emma (Colección, viernes). **Crea** el archivo en 4 partes.

📄 **`app_flutter/lib/presentation/app_shell.dart`** · parte 1 de 4 (líneas 1–37) · empieza el archivo · **versión provisional**

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'home_page.dart';
import 'navigation.dart';
import 'pendiente.dart';
import 'theme.dart';
import 'widgets/court_button.dart';

// --- La app ---

class CourtApp extends StatefulWidget {
  final AppController app;
  const CourtApp({super.key, required this.app});
  @override
  State<CourtApp> createState() => _CourtAppState();
}

class _CourtAppState extends State<CourtApp> {
  final tab = ValueNotifier<int>(Tabs.home);

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: kBrand,
    theme: buildTheme(),
    debugShowCheckedModeBanner: false,
    // TabScope envuelve al Navigator: todas las pantallas pueden cambiar
    // de pestaña con goToTab().
    builder: (context, child) => TabScope(tab: tab, child: child!),
    home: AppShell(app: widget.app, tab: tab),
  );
}
```

- `CourtApp` es `StatefulWidget` porque **es dueño** del `ValueNotifier` de la pestaña: lo crea una vez y lo libera en `dispose()`.
- `MaterialApp.builder` envuelve al `Navigator` con `TabScope`. Así **todas** las rutas, incluso las que se abren después, encuentran la pestaña.

📄 **`app_flutter/lib/presentation/app_shell.dart`** · parte 2 de 4 (líneas 39–75) · sigue debajo de la parte anterior · **versión provisional**

```dart
// --- La cáscara: carga, error o pestañas ---

class AppShell extends StatelessWidget {
  final AppController app;
  final ValueNotifier<int> tab;
  const AppShell({super.key, required this.app, required this.tab});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([app, tab]),
    builder: (context, _) {
      if (app.loading) return const _LoadingView();
      if (app.error != null) {
        return _ErrorView(message: app.error!, onRetry: app.load);
      }
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab.value,
            children: [
              HomePage(app: app),
              const PantallaPendiente('Colección', owner: 'Emma · viernes'),
              const PantallaPendiente('Sobres', owner: 'Miguel · jueves'),
              const PantallaPendiente('Jugar', owner: 'Sebastián · viernes'),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          selected: tab.value,
          packDot: app.canOpenPack,
          onSelect: (value) => tab.value = value,
        ),
      );
    },
  );
}
```

- `Listenable.merge([app, tab])`: la cáscara se redibuja si cambian los datos **o** la pestaña.
- Tres estados: cargando, error (con Reintentar) o las pestañas.
- `IndexedStack` mantiene vivas las 4 pestañas. Al volver a Colección, el scroll y la búsqueda siguen donde estaban.

📄 **`app_flutter/lib/presentation/app_shell.dart`** · parte 3 de 4 (líneas 77–144) · sigue debajo de la parte anterior · **versión provisional**

```dart
// --- Barra inferior ---

/// Barra inferior del mockup: píldora verde oscuro con ícono verde limón.
class _BottomNav extends StatelessWidget {
  final int selected;
  final bool packDot; // punto rojo si hay sobre por abrir
  final ValueChanged<int> onSelect;
  const _BottomNav({
    required this.selected,
    required this.packDot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Court.line)),
    ),
    child: NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Court.c800,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 21,
            color: states.contains(WidgetState.selected)
                ? Court.ball
                : Court.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? body(11.5, weight: FontWeight.w700, color: Court.c900)
              : body(11.5, weight: FontWeight.w500, color: Court.muted),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: onSelect,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.style_outlined),
            label: 'Colección',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: packDot,
              smallSize: 8,
              backgroundColor: Court.loss,
              child: const Icon(Icons.inventory_2_outlined),
            ),
            label: 'Sobres',
          ),
          const NavigationDestination(
            icon: Icon(Icons.sports_baseball_outlined),
            label: 'Jugar',
          ),
        ],
      ),
    ),
  );
}
```

- Es la `NavigationBar` de Material con el tema del mockup: píldora `c800` e ícono verde limón en la pestaña activa.
- `WidgetStateProperty.resolveWith` elige el estilo según el estado: seleccionada o no.
- `Badge` pone un punto rojo en Sobres si el sobre de hoy está sin abrir.

📄 **`app_flutter/lib/presentation/app_shell.dart`** · parte 4 de 4 (líneas 146–252) · sigue debajo de la parte anterior · **versión provisional**

```dart
// --- Logo, carga y error ---

/// Logo cuadrado de la marca (también se usa en Inicio).
class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Court.c800,
      borderRadius: BorderRadius.circular(size / 3),
    ),
    child: Icon(
      Icons.sports_baseball_outlined,
      color: Court.ball,
      size: size * 0.56,
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandLogo(size: 64),
          const SizedBox(height: 20),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 12),
          Text('Cargando tenistas…', style: body(14, color: Court.muted)),
        ],
      ),
    ),
  );
}

/// Error de carga del catálogo, con Reintentar (como en Colección del mockup).
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Court.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xfff6e3de),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Court.loss,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar los tenistas',
              textAlign: TextAlign.center,
              style: display(19, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Revisa tu conexión e inténtalo de nuevo. '
              'Tus cartas siguen guardadas en este dispositivo.',
              textAlign: TextAlign.center,
              style: body(14, color: Court.muted),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: body(11, color: Court.disabledText),
            ),
            const SizedBox(height: 20),
            CourtButton('Reintentar', icon: Icons.refresh, onPressed: onRetry),
          ],
        ),
      ),
    ),
  );
}
```

- `BrandLogo` es público (sin `_`) porque el Inicio de Emma también lo usa.
- `_LoadingView` y `_ErrorView` son las pantallas de carga y de error. El error explica qué pasó y que las cartas siguen guardadas.

Inicio **provisional** (Emma lo reemplaza el viernes por el del mockup):

📄 **`app_flutter/lib/presentation/home_page.dart`** · 50 líneas · **versión provisional**

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/court_button.dart';

/// Inicio PROVISIONAL: solo para navegar mientras se construyen las
/// pantallas. Emma lo reemplaza el viernes por el Inicio del mockup.
class HomePage extends StatelessWidget {
  final AppController app;
  const HomePage({super.key, required this.app});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(kBrand, style: display(22)),
      const SizedBox(height: 16),
      Text('Hola, ${app.nickname}', style: body(14, color: Court.muted)),
      Text(
        '${app.uniqueCount} de ${app.catalog.length} cartas únicas',
        style: display(24),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: app.uniqueCount / app.catalog.length),
      const SizedBox(height: 24),
      CourtButton(
        'Jugar partida',
        variant: ButtonVariant.accent,
        size: ButtonSize.lg,
        full: true,
        onPressed: () => goToTab(context, Tabs.play),
      ),
      const SizedBox(height: 8),
      CourtButton(
        app.canOpenPack ? 'Abrir sobre diario' : 'Sobre abierto · mañana hay otro',
        variant: ButtonVariant.secondary,
        full: true,
        onPressed: () => goToTab(context, Tabs.packs),
      ),
      const SizedBox(height: 8),
      CourtButton(
        'Colección',
        variant: ButtonVariant.secondary,
        full: true,
        onPressed: () => goToTab(context, Tabs.collection),
      ),
    ],
  );
}
```

Y el `main.dart` **definitivo**:

📄 **`app_flutter/lib/main.dart`** · 16 líneas

```dart
import 'package:flutter/material.dart';
import 'application/app_controller.dart';
import 'data/catalog_repository.dart';
import 'data/local_store.dart';
import 'presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  final controller = AppController(
    CatalogRepository(baseUrl),
    FileLocalStore(baseUrl.isEmpty ? 'demo' : 'rapidapi'),
  );
  runApp(CourtApp(app: controller));
  await controller.load();
}
```

**Entiende `main.dart`**
- `String.fromEnvironment('API_BASE_URL')` se fija al compilar con `--dart-define=API_BASE_URL=…`. Si no se entrega, queda vacío y la app es demo.
- El progreso demo y el de la API se guardan en archivos distintos (`spintcg_demo.json` y `spintcg_rapidapi.json`), así no se mezclan cartas ficticias con reales.
- `runApp` va **antes** de `load()`: la app muestra «Cargando tenistas…» mientras carga, en vez de una pantalla negra.

```bash
dart format lib && flutter analyze
flutter run -d linux
```

Se ve la barra inferior del mockup. Inicio (provisional) cambia de pestaña, y las otras dicen «En construcción · …». Para ver el estado de error: `flutter run -d linux --dart-define=API_BASE_URL=http://127.0.0.1:9999` (ahí no escucha nadie) → «No pudimos cargar los tenistas» con Reintentar.

## Paso 3 · Primera prueba automática

📄 **`app_flutter/test/catalog_test.dart`** · 60 líneas

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/demo_catalog.dart';

void main() {
  test(
    'Consume /catalog y valida seis cartas normalizadas sin clave en el cliente',
    () async {
      final repository = CatalogRepository(
        'http://localhost:8787',
        client: MockClient((request) async {
          expect(request.url.path, '/catalog');
          expect(request.headers.containsKey('X-RapidAPI-Key'), false);
          // Response.bytes: los nombres traen tildes (Miñaur, Cerúndolo).
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'source': 'rapidapi',
                'cards': demoCatalog().map((c) => c.toJson()).toList(),
              }),
            ),
            200,
          );
        }),
      );
      expect((await repository.load()).length, 24);
      repository.dispose();
    },
  );
  test(
    'Error del servidor se muestra sin sustituirlo por datos ficticios',
    () async {
      final repository = CatalogRepository(
        'http://localhost:8787',
        client: MockClient((_) async => http.Response('{}', 429)),
      );
      await expectLater(repository.load(), throwsStateError);
      repository.dispose();
    },
  );
  test('Catálogo incompleto rechazado', () async {
    final repository = CatalogRepository(
      'http://localhost:8787',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'source': 'rapidapi',
            'cards': [demoCatalog().first.toJson()],
          }),
          200,
        ),
      ),
    );
    await expectLater(repository.load(), throwsFormatException);
    repository.dispose();
  });
}
```

**Entiende**
- `MockClient` reemplaza la red: la prueba decide qué responde el «servidor».
- La primera prueba revisa que la app pida `/catalog` **sin** enviar `X-RapidAPI-Key`. Esa es la regla de seguridad del proyecto.
- `http.Response.bytes(utf8.encode(...))`: los nombres traen tildes, y así se simula lo que manda el servidor real.
- Un error 429 (cuota agotada) debe terminar en error, **no** en datos demo. Un catálogo de 1 carta se rechaza.

```bash
dart format test && flutter analyze && flutter test     # 3 pruebas en verde
git add -A && git commit -m "Cáscara con barra inferior, main y prueba del catálogo"
git push -u origin sebastian/dia2-cascara && gh pr create --fill
```

---

## Tarde: el servidor intermediario (rama `sebastian/dia2-servidor`)

La app nunca habla con RapidAPI: habla con este servidor Node, que guarda la clave. Desde la raíz del repo:

```bash
git switch main && git pull && git switch -c sebastian/dia2-servidor
mkdir -p servidor_api/fixtures && cd servidor_api
```

### Paso 4 · `.gitignore` del servidor

**Crea** `servidor_api/.gitignore`:

📄 **`servidor_api/.gitignore`** · 3 líneas

```gitignore
.local/
.env
*.log
```

- `.local/` guarda la caché y el presupuesto; `.env`, la clave si la pones en un archivo. Ninguno se sube.

### Paso 5 · El adaptador: de RapidAPI a cartas

**Crea** `servidor_api/adapter.mjs` en 4 partes. Los nombres de campos salen de la [documentación de la API](https://tennisapidoc.matchstat.com/players) (revisada en [`../../api-tennis.md`](../../api-tennis.md)).

📄 **`servidor_api/adapter.mjs`** · parte 1 de 4 (líneas 1–12) · empieza el archivo

```js
// --- Validar números ---

/** Convierte a número o lanza un error. Un dato faltante NUNCA se vuelve 0. */
export function numeric(value, label) {
  const missing =
    value === null || value === undefined || value === '' || typeof value === 'boolean';
  if (missing) throw new Error(`Falta ${label}`);

  const n = Number(value);
  if (!Number.isFinite(n) || n < 0) throw new Error(`Valor inválido: ${label}`);
  return n;
}
```

- `numeric()` **no inventa ceros**: un dato faltante es un error, no un 0. Es mejor saltar a un tenista que mostrar estadísticas falsas.
- `export` permite usar la función desde otro archivo (`server.mjs` y las pruebas).

📄 **`servidor_api/adapter.mjs`** · parte 2 de 4 (líneas 14–34) · sigue debajo de la parte anterior

```js
// --- Leer un récord de victorias y derrotas ---

/**
 * La documentación da el récord como texto "450-133" en su ejemplo, pero su
 * tabla de campos dice "objeto". Se aceptan las formas conocidas:
 * "450-133", { wins, losses } y { w, l }. Cualquier otra cosa es un error.
 */
export function parseRecord(record, label) {
  if (typeof record === 'string') {
    const match = /^\s*(\d+)\s*-\s*(\d+)\s*$/.exec(record);
    if (!match) throw new Error(`Formato inválido: ${label} = "${record}"`);
    return { wins: Number(match[1]), losses: Number(match[2]) };
  }
  if (record && typeof record === 'object') {
    return {
      wins: numeric(record.wins ?? record.w, `${label} (victorias)`),
      losses: numeric(record.losses ?? record.l, `${label} (derrotas)`),
    };
  }
  throw new Error(`Falta ${label}`);
}
```

- La API entrega el récord de carrera como texto: `"total": "450-133"`. Pero su propia tabla de campos dice que es un objeto. `parseRecord` acepta las dos formas y falla con cualquier otra.
- `/^\s*(\d+)\s*-\s*(\d+)\s*$/` es una expresión regular: «número, guion, número». `match[1]` y `match[2]` son los dos números.

📄 **`servidor_api/adapter.mjs`** · parte 3 de 4 (líneas 36–69) · sigue debajo de la parte anterior

```js
// --- Un tenista ---

/**
 * Junta una fila del ranking y las estadísticas de carrera de ese tenista
 * en una carta: { id, name, country, ranking, titles, winRate }.
 */
export function normalizePlayer(rankingRow, response) {
  const stats = response.data ?? response;
  const player = rankingRow.player;
  if (!player || !player.name || !player.id) {
    throw new Error('Ranking sin identidad de tenista');
  }

  // Récord de carrera: "total" (por ejemplo "450-133").
  const { wins, losses } = parseRecord(stats.total, 'total');
  if (wins + losses === 0) throw new Error('Sin partidos para calcular porcentaje');

  const position = numeric(rankingRow.position, 'position');
  if (position < 1) throw new Error('Ranking debe ser positivo');

  // Títulos ganados. Ojo: en el ejemplo oficial, totalTitles (36) es
  // totalTitlesWon (31) + totalFinalsWon (5), o sea, finales jugadas.
  // Por eso se usa SOLO totalTitlesWon.
  const titles = numeric(stats.totalTitlesWon, 'totalTitlesWon');

  return {
    id: `atp-${player.id}`,
    name: player.name,
    country: player.countryAcr ?? player.country?.acronym ?? 'N/D',
    ranking: position,
    titles,
    winRate: Math.round((1000 * wins) / (wins + losses)) / 10, // un decimal
  };
}
```

- `normalizePlayer` junta una fila del ranking (`position`, `player.id`, `name`, `countryAcr`) con las estadísticas de carrera (`total` y `totalTitlesWon`).
- **Títulos = `totalTitlesWon`, y solo ese campo.** En el ejemplo oficial, `totalTitles` (36) = `totalTitlesWon` (31) + `totalFinalsWon` (5): son finales jugadas, no títulos.
- `a ?? b`: usa `a` y, si no existe, `b` (el país viene en `countryAcr` o en `country.acronym`).
- El % de victorias se redondea a un decimal: `Math.round(1000 * w / total) / 10`.

📄 **`servidor_api/adapter.mjs`** · parte 4 de 4 (líneas 71–111) · sigue debajo de la parte anterior

```js
// --- El catálogo completo ---

/**
 * 1 consulta de ranking + 1 de estadísticas por tenista (máximo 25).
 * `request` es la función que llama a RapidAPI: en las pruebas es falsa.
 */
export async function fetchCatalog(request, { count = 24 } = {}) {
  const ranking = await request(`/tennis/v2/atp/ranking/singles?pageNo=1&pageSize=${count}`);
  if (!Array.isArray(ranking.data)) throw new Error('Ranking: se esperaba data[]');

  const cards = [];
  const skipped = []; // tenistas descartados y el motivo
  for (const row of ranking.data.slice(0, count)) {
    if (!row.player?.id) {
      skipped.push('Fila sin ID');
      continue;
    }
    const id = encodeURIComponent(row.player.id);
    const stats = await request(`/tennis/v2/profile/${id}/statistics?type=atp&includeAll=true`);
    try {
      const card = normalizePlayer(row, stats);
      if (!cards.some((c) => c.id === card.id)) cards.push(card);
    } catch (error) {
      skipped.push(`${row.player.name ?? row.player.id}: ${error.message}`);
    }
  }

  if (cards.length < 6) {
    throw new Error(
      `Solo ${cards.length} tenistas completos; se requieren al menos seis. ` +
        `Validar el esquema real: ${skipped.join('; ')}`,
    );
  }
  return {
    source: 'rapidapi',
    period: 'career',
    fetchedAt: new Date().toISOString(),
    cards,
    skipped,
  };
}
```

- `fetchCatalog` hace **1 consulta de ranking + 1 por tenista**: máximo 25 consultas por actualización.
- `request` llega como parámetro: el servidor le pasa la función real, y las pruebas una falsa.
- Los tenistas con datos incompletos van a `skipped` con el motivo. Con menos de 6 cartas válidas, falla y dice qué revisar.

### Paso 6 · El servidor

**Crea** `servidor_api/server.mjs` en 4 partes.

📄 **`servidor_api/server.mjs`** · parte 1 de 4 (líneas 1–38) · empieza el archivo

```js
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { setTimeout as delay } from 'node:timers/promises';
import { fetchCatalog } from './adapter.mjs';

// --- Configuración ---

const host = 'tennis-api-atp-wta-itf.p.rapidapi.com';
const key = process.env.RAPIDAPI_KEY; // la clave SOLO vive aquí, nunca en la app
const port = Number(process.env.PORT ?? 8787);

// Caché y presupuesto en servidor_api/.local/ (ignorado por git).
const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), '.local');
const cacheFile = path.join(dir, 'catalog.json');
const budgetFile = path.join(dir, 'budget.json');

const DAY = 24 * 60 * 60 * 1000; // el catálogo dura 24 horas
const MAX_REQUESTS_PER_DAY = 40;
const RETRY_WAIT = 5 * 60 * 1000; // tras un fallo, esperar 5 minutos

let catalog; // última respuesta buena
let budget = { since: Date.now(), count: 0 }; // consultas hechas en 24 h
let pending; // actualización en curso (para no lanzar dos a la vez)
let cooldown = 0; // hasta cuándo no se reintenta

// Al arrancar, recuperar lo guardado (si existe).
try {
  catalog = JSON.parse(await fs.readFile(cacheFile, 'utf8'));
} catch {
  // Sin caché previa.
}
try {
  budget = JSON.parse(await fs.readFile(budgetFile, 'utf8'));
} catch {
  // Primer uso.
}
```

- La clave se lee de `process.env.RAPIDAPI_KEY`: **nunca** está escrita en el código ni en la app.
- Al arrancar, recupera la caché y el presupuesto guardados en `.local/`. Si no existen (primer uso), el `catch` vacío deja los valores iniciales.

📄 **`servidor_api/server.mjs`** · parte 2 de 4 (líneas 40–66) · sigue debajo de la parte anterior

```js
// --- Una consulta a RapidAPI ---

async function request(endpoint) {
  if (!key) throw new Error('Configura RAPIDAPI_KEY en el servidor');

  // Presupuesto: máximo 40 consultas cada 24 horas.
  if (Date.now() - budget.since >= DAY) budget = { since: Date.now(), count: 0 };
  if (budget.count >= MAX_REQUESTS_PER_DAY) {
    throw new Error('Presupuesto local diario agotado; esperar 24 horas');
  }
  budget.count++;
  await fs.mkdir(dir, { recursive: true });
  await fs.writeFile(budgetFile, JSON.stringify(budget));

  await delay(300); // pausa entre consultas para no saturar la API
  const response = await fetch(`https://${host}${endpoint}`, {
    headers: { 'X-RapidAPI-Key': key, 'X-RapidAPI-Host': host },
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) {
    // 401 = clave mala, 403 = plan sin acceso, 429 = cuota o velocidad agotada.
    const body = await response.json().catch(() => ({}));
    const detail = body.message ?? body.error ?? 'revisar plan y cuota';
    throw new Error(`RapidAPI HTTP ${response.status}: ${detail}`);
  }
  return response.json();
}
```

- **Presupuesto:** máximo 40 consultas cada 24 h, contadas en `.local/budget.json`. Se guarda **antes** de consultar, para que una caída no «regale» consultas.
- La clave viaja en el encabezado `X-RapidAPI-Key`, solo entre el servidor y RapidAPI.
- Si RapidAPI responde con error, el mensaje incluye su explicación: 401 (clave mala), 403 (`plan_restricted`) o 429 (cuota o velocidad agotada).
- `AbortSignal.timeout(15000)`: si RapidAPI no responde en 15 s, se corta.

📄 **`servidor_api/server.mjs`** · parte 3 de 4 (líneas 68–95) · sigue debajo de la parte anterior

```js
// --- El catálogo, con caché ---

async function getCatalog() {
  // Si el catálogo tiene menos de 24 horas, se entrega sin consultar.
  if (catalog && Date.now() - Date.parse(catalog.fetchedAt) < DAY) return catalog;
  if (Date.now() < cooldown) {
    throw new Error('Actualización fallida; reintentar en cinco minutos');
  }
  pending ??= refresh();
  return pending;
}

async function refresh() {
  try {
    const next = await fetchCatalog(request);
    // Escritura segura: primero .tmp y después se renombra.
    await fs.mkdir(dir, { recursive: true });
    await fs.writeFile(`${cacheFile}.tmp`, JSON.stringify(next));
    await fs.rename(`${cacheFile}.tmp`, cacheFile);
    catalog = next;
    return next;
  } catch (error) {
    cooldown = Date.now() + RETRY_WAIT;
    throw error;
  } finally {
    pending = undefined;
  }
}
```

- **Caché de 24 h:** la app puede pedir el catálogo las veces que quiera; RapidAPI se consulta como máximo una vez al día.
- `pending ??= refresh()`: si ya hay una actualización en curso, se espera esa misma en vez de lanzar otra.
- Si la actualización falla, espera 5 minutos antes de reintentar (`cooldown`).

📄 **`servidor_api/server.mjs`** · parte 4 de 4 (líneas 97–118) · sigue debajo de la parte anterior

```js
// --- Rutas HTTP ---

function send(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  if (req.method !== 'GET') return send(res, 405, { error: 'Método no permitido' });
  if (req.url === '/health') return send(res, 200, { ok: true, keyConfigured: Boolean(key) });
  if (req.url !== '/catalog') return send(res, 404, { error: 'Ruta no encontrada' });
  try {
    send(res, 200, await getCatalog());
  } catch (error) {
    send(res, 503, { error: error.message });
  }
});

// Solo 127.0.0.1: nadie más en la red puede usarlo.
server.listen(port, '127.0.0.1', () => {
  console.log(`Servidor local: http://127.0.0.1:${port} (clave configurada: ${Boolean(key)})`);
});
```

- Tres rutas: `GET /health` (¿está vivo? ¿tiene clave?), `GET /catalog` y 404 para todo lo demás.
- Si algo falla, responde **503** con el mensaje: la app lo muestra como error, nunca como datos inventados.
- Escucha solo en `127.0.0.1`: nadie más en la red puede usarlo. El teléfono llega por `adb reverse`.

### Paso 7 · Pruebas del adaptador

**Crea** `servidor_api/adapter.test.mjs`:

📄 **`servidor_api/adapter.test.mjs`** · 51 líneas

```js
import test from 'node:test';
import assert from 'node:assert/strict';
import { normalizePlayer, fetchCatalog, parseRecord } from './adapter.mjs';

test('Respuesta de ejemplo de la documentación (récord como texto)', () => {
  // Fila del ranking y estadísticas copiadas de tennisapidoc.matchstat.com.
  const row = { position: 1, player: { id: 47275, name: 'Jannik Sinner', countryAcr: 'ITA' } };
  const stats = { total: '450-133', totalTitles: 36, totalTitlesWon: 31, totalFinalsWon: 5 };
  assert.deepEqual(normalizePlayer(row, stats), {
    id: 'atp-47275',
    name: 'Jannik Sinner',
    country: 'ITA',
    ranking: 1,
    titles: 31, // totalTitlesWon, no totalTitles
    winRate: 77.2, // 450 / 583
  });
});

test('El récord también se acepta como objeto', () => {
  assert.deepEqual(parseRecord({ wins: 3, losses: 1 }, 'total'), { wins: 3, losses: 1 });
  assert.deepEqual(parseRecord({ w: '3', l: '1' }, 'total'), { wins: 3, losses: 1 });
});

test('Datos faltantes o raros no se convierten en ceros ficticios', () => {
  const row = { position: 1, player: { id: 1, name: 'A' } };
  assert.throws(() => normalizePlayer(row, { total: { wins: 2 }, totalTitlesWon: 3 }));
  assert.throws(() => normalizePlayer(row, { total: '12 victorias', totalTitlesWon: 3 }));
  assert.throws(() => normalizePlayer(row, { total: '10-2' })); // sin títulos
});

test('Una consulta de ranking y una de carrera por jugador; mínimo seis', async () => {
  const calls = [];
  // RapidAPI falsa: 6 tenistas en el ranking, todos con estadísticas.
  const fakeRequest = async (endpoint) => {
    calls.push(endpoint);
    if (endpoint.includes('ranking/singles')) {
      return {
        data: Array.from({ length: 6 }, (_, i) => ({ position: i + 1, player: { id: i + 1, name: `P${i}` } })),
      };
    }
    return { total: '9-1', totalTitlesWon: 1 };
  };

  const catalog = await fetchCatalog(fakeRequest, { count: 6 });
  assert.equal(catalog.cards.length, 6);
  assert.equal(calls.length, 7); // 1 ranking + 6 estadísticas
  assert.equal(catalog.source, 'rapidapi');

  // Un ranking vacío no alcanza las 6 cartas mínimas.
  await assert.rejects(() => fetchCatalog(async () => ({ data: [] }), { count: 6 }));
});
```

- La primera prueba usa **la respuesta de ejemplo de la documentación**, tal cual: si el parser la acepta, la API real también debería pasar.
- Las pruebas usan una RapidAPI **falsa** (`fakeRequest`): no gastan cuota ni necesitan clave.
- La última cuenta las consultas: 1 de ranking + 6 de estadísticas = 7.

```bash
node --test adapter.test.mjs      # 4 pruebas en verde, sin red ni clave
node server.mjs                   # sin clave: arranca y avisa «clave configurada: false»
curl http://127.0.0.1:8787/health
```

```bash
cd .. && git add servidor_api && git commit -m "Servidor intermediario con caché y presupuesto"
git push -u origin sebastian/dia2-servidor && gh pr create --fill
```

## Paso 8 · API real

Las dos consultas a mano (sin que la clave quede en el historial) y el `/catalog` completo están en el miércoles y el jueves de [`../../plan-crunch/sebastian.md`](../../plan-crunch/sebastian.md):

- [ ] `fixtures/ranking-singles.json` y `fixtures/player-statistics.json` guardados **sin** encabezados ni clave.
- [ ] Comparar con `adapter.mjs` y ajustar el parser si el esquema real difiere. Agregar una prueba con los fixtures.
- [ ] `node server.mjs` con la clave → `curl /catalog`: ¿cuántas cartas llegan? ¿qué dice `skipped`?
- [ ] App con datos reales: `flutter run -d linux --dart-define=API_BASE_URL=http://127.0.0.1:8787`.

## Cierre del día

- [ ] En `main`: navegación, cáscara, `main.dart`, prueba del catálogo y servidor.
- [ ] Integrados los PR del día 2 de Emma (equipo y Detalle) y de Miguel (Sobres, que reemplaza su pestaña provisional).
- [ ] Check-in de las 21:00.
