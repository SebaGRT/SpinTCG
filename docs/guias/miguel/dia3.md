<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Miguel · Día 3 (viernes 23): Perfil y Resultado

**Meta del día:** el Perfil del mockup, con el error del apodo dentro del campo, y la pantalla Resultado, que **guarda la partida** en el progreso.

← [Día 2](dia2.md) · [Índice](../README.md) · Siguiente: [Día 4](dia4.md)

## Mapa del día

| Paso | Qué haces | Archivo | Depende de |
|---|---|---|---|
| 1 | Perfil | `lib/presentation/profile_page.dart` | — · **PR antes de las 12:00** (Emma lo usa en Inicio) |
| 2 | Mirar el Perfil | `lib/muestra.dart` (no se sube) | — |
| 3 | Resultado | `lib/presentation/result_page.dart` | `match_page.dart` de Sebastián (hoy, 12:00) |
| 4 | Conectar Partida con Resultado | `lib/presentation/match_page.dart` (solo `next()` y 2 imports) | — · **PR antes de las 15:00** |

**Tiempo:** unas 3 h (~575 líneas). [Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

```bash
git switch main && git pull
git switch -c miguel/dia3-perfil
cd app_flutter
```

---

## Paso 1 · Perfil

**Crea** el archivo en 4 partes.

📄 **`app_flutter/lib/presentation/profile_page.dart`** · parte 1 de 4 (líneas 1–39) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'errores.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';

// --- Estado y guardado ---

class ProfilePage extends StatefulWidget {
  final AppController app;
  const ProfilePage({super.key, required this.app});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final nickname = TextEditingController(text: widget.app.nickname);
  bool editing = false;
  String? error; // se muestra dentro del campo

  @override
  void dispose() {
    nickname.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      await widget.app.saveNickname(nickname.text);
      if (!mounted) return;
      setState(() {
        editing = false;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = mensajeDeError(e));
    }
  }
```

- Dos modos: **ver** (apodo grande con el lápiz) y **editar** (campo + Guardar). El `bool editing` cambia entre ellos.
- `late final nickname = TextEditingController(...)` se crea la primera vez que se usa, y `dispose()` lo libera. Todo controlador de texto se libera.
- Si el apodo no es válido, `error` guarda el mensaje (`mensajeDeError`) y el campo lo muestra. Si se guarda bien, vuelve a `null`.
- `if (!mounted) return;` después del `await`, igual que en Sobres.

📄 **`app_flutter/lib/presentation/profile_page.dart`** · parte 2 de 4 (líneas 41–70) · sigue debajo de la parte anterior

```dart
  // --- Reglas en una hoja ---

  void showRules() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cómo se juega', style: display(20)),
          const SizedBox(height: 12),
          Text(
            'Juegas tres rondas contra la computadora. En cada ronda eliges '
            'una carta de tu equipo y se compara un atributo fijo. Cada carta '
            'se usa una sola vez; si los valores son iguales, la ronda queda '
            'empatada.',
            style: body(14, color: Court.muted),
          ),
          const SizedBox(height: 12),
          const RulesList(),
          const SizedBox(height: 4),
          Text(
            'Gana la partida quien consiga más rondas.',
            style: body(13, color: Court.muted),
          ),
        ],
      ),
    ),
  );
```

- «Cómo se juega» abre una hoja inferior (`showModalBottomSheet`) con tu `RulesList` del miércoles.

📄 **`app_flutter/lib/presentation/profile_page.dart`** · parte 3 de 4 (líneas 72–174) · sigue debajo de la parte anterior

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            TopBar('Perfil', onBack: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            const Center(child: Avatar(size: 96)),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Avatar predeterminado',
                style: body(12, color: Court.muted),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: editing ? _editor(app) : _nickname(),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Apodo · máximo 16 caracteres',
                style: body(12, color: Court.muted),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // IntrinsicHeight + stretch: las tres cajas con la misma altura.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatBox(
                        label: 'Cartas únicas',
                        value: '${app.uniqueCount}/${app.catalog.length}',
                        emphasis: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: 'Partidas',
                        value: '${app.played}',
                        hint: 'jugadas',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: 'Victorias',
                        value: '${app.wins}',
                        hint: app.played == 0
                            ? 'sin partidas'
                            : '${(app.wins * 100 / app.played).round()}% del total',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Court.line),
                ),
                child: ListTile(
                  onTap: showRules,
                  leading: const Icon(Icons.info_outline, color: Court.c700),
                  title: Text(
                    'Cómo se juega',
                    style: body(15, weight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Court.muted),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Tu perfil se guarda solo en este dispositivo. '
                'No necesitas registrarte.',
                textAlign: TextAlign.center,
                style: body(12, color: Court.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
```

- Avatar grande, el apodo (en modo ver o editar), las tres cajas de estadísticas y el acceso a «Cómo se juega».
- **`IntrinsicHeight` + `CrossAxisAlignment.stretch`:** las tres cajas quedan del mismo alto aunque una no tenga la línea de abajo, igual que la grilla del mockup.
- El % de victorias se calcula solo si hay partidas: así nunca se divide por cero.

📄 **`app_flutter/lib/presentation/profile_page.dart`** · parte 4 de 4 (líneas 176–260) · sigue debajo de la parte anterior

```dart
  // --- Ver y editar el apodo ---

  /// Apodo grande con el lápiz para editar.
  Widget _nickname() => Center(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => editing = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(widget.app.nickname, style: display(26))),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Editar apodo',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Court.line),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: Court.c700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// Campo de texto + Guardar. El error aparece bajo el campo.
  Widget _editor(AppController app) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TextField(
          controller: nickname,
          autofocus: true,
          maxLength: 16,
          onSubmitted: (_) => save(),
          style: display(17, weight: FontWeight.w700),
          decoration: InputDecoration(
            counterText: '',
            errorText: error,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.c600, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.c600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.loss, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.loss, width: 2),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      CourtButton(
        'Guardar',
        icon: Icons.check,
        onPressed: app.busy ? null : save,
      ),
    ],
  );
}
```

- El error se muestra **dentro del campo** con `InputDecoration.errorText`, no en un SnackBar.
- `maxLength: 16` corta lo que se escribe; `counterText: ''` oculta el contador «0/16». La regla real está en el controlador: un apodo de solo espacios igual se rechaza.
- Los cuatro bordes (`enabled`, `focused`, `error`, `focusedError`) cubren cada estado del campo: verde normal y rojo con error.

## Paso 2 · Mirar el Perfil

Todavía no se llega al Perfil desde la app (el avatar de Inicio llega con Emma). Reemplaza tu `lib/muestra.dart`:

📄 **`app_flutter/lib/muestra.dart`** · 24 líneas · **versión provisional**

```dart
// Abre el Perfil con datos demo, sin tocar la app.
// Ejecutar: flutter run -t lib/muestra.dart   (NO se sube al repo)
import 'package:flutter/material.dart';
import 'application/app_controller.dart';
import 'data/catalog_repository.dart';
import 'data/local_store.dart';
import 'presentation/profile_page.dart';
import 'presentation/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Catálogo demo y progreso en memoria: se pierde al cerrar.
  final app = AppController(CatalogRepository(''), MemoryLocalStore());
  await app.load();
  runApp(
    MaterialApp(
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ProfilePage(app: app),
      ),
    ),
  );
}
```

```bash
dart format lib && flutter analyze && flutter test
flutter run -d linux -t lib/muestra.dart
```

Lápiz → borra todo → Guardar: aparece «Usa un apodo de 1 a 16 caracteres» **bajo el campo**. Escribe «Miguel» → Guardar → vuelve al modo ver. «Cómo se juega» abre la hoja con las reglas. (En la muestra, ← cierra la única pantalla y queda negro: es normal).

```bash
git add -A && git commit -m "Perfil del mockup con error en el campo"
git push -u origin miguel/dia3-perfil
gh pr create --fill
```

📣 Avisa a Emma y a Sebastián: «Perfil en PR».

## Paso 3 · Resultado (después de la Partida de Sebastián)

```bash
git switch main && git pull && git switch -c miguel/dia3-resultado
```

Aquí la partida se convierte en progreso guardado. **Crea** el archivo en 5 partes.

📄 **`app_flutter/lib/presentation/result_page.dart`** · parte 1 de 5 (líneas 1–67) · empieza el archivo

```dart
import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/game.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'match_page.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/player_card.dart';

// --- Guardar la partida ---

/// Resultado de la partida. Al abrirse guarda la partida en el progreso.
class ResultPage extends StatefulWidget {
  final AppController app;
  final MatchSession match;
  const ResultPage({super.key, required this.app, required this.match});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool saving = false; // guardando ahora
  bool saved = false; // ya quedó guardada
  String? saveError; // mensaje si falló el guardado

  MatchSession get m => widget.match;

  /// 1 = ganaste, -1 = perdiste, 0 = empate.
  int get outcome => (m.playerScore - m.opponentScore).sign;

  @override
  void initState() {
    super.initState();
    // Se guarda después del primer frame: guardar avisa al controlador, y
    // no se puede redibujar mientras esta pantalla se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) => record());
  }

  /// Suma la partida al progreso. Se puede reintentar sin contarla dos veces.
  Future<void> record() async {
    setState(() {
      saving = true;
      saveError = null;
    });
    try {
      await widget.app.recordMatch(widget.match);
      saved = true;
    } catch (e) {
      saveError = 'No se guardó el resultado: ${mensajeDeError(e)}';
    }
    if (mounted) setState(() => saving = false);
  }

  /// Nueva partida con el mismo equipo; reemplaza esta pantalla.
  void playAgain() {
    final match = widget.app.startMatch();
    openPage(
      context,
      widget.app,
      () => MatchPage(app: widget.app, match: match),
      replace: true,
    );
  }
```

- `outcome` resume la partida en 1 (ganaste), -1 (perdiste) o 0 (empate). `.sign` da el signo de la resta de los puntajes.
- Al abrirse, la pantalla llama a `record()` → `app.recordMatch(match)`, que suma una partida jugada (y una victoria si ganaste) dentro de `_change()`. Si falla al escribir, se revierte.
- **¿Por qué `addPostFrameCallback`?** Guardar avisa al controlador (`notifyListeners`), y la pantalla se está construyendo justo en ese momento. Redibujar durante la construcción es un error de Flutter: por eso el guardado espera al primer frame.
- Tres estados: `saving` (barra de progreso), `saved` («Resultado guardado») y `saveError` (mensaje y «Reintentar guardado»). Reintentar es seguro: `recordMatch` nunca cuenta la misma partida dos veces.

📄 **`app_flutter/lib/presentation/result_page.dart`** · parte 2 de 5 (líneas 69–80) · sigue debajo de la parte anterior

```dart
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving, // no se puede salir mientras se guarda
    child: Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [_header(), _summary(context)],
      ),
    ),
  );
```

- `PopScope(canPop: !saving)`: no se puede salir con ← mientras se guarda.
- La pantalla es una lista con dos bloques: encabezado y resumen.

📄 **`app_flutter/lib/presentation/result_page.dart`** · parte 3 de 5 (líneas 82–192) · sigue debajo de la parte anterior

```dart
  // --- Encabezado según el resultado ---

  Widget _header() {
    final win = outcome == 1;
    final String title;
    final String subtitle;
    final IconData icon;
    final Color background;
    final Color iconColor;
    switch (outcome) {
      case 1:
        title = '¡Victoria!';
        subtitle = 'Ganaste la partida contra la computadora.';
        icon = Icons.emoji_events_outlined;
        background = Court.c800;
        iconColor = Court.c900;
      case -1:
        title = 'Derrota';
        subtitle = 'La computadora ganó esta vez. ¡Prueba otra vez!';
        icon = Icons.close;
        background = Court.segment;
        iconColor = Court.loss;
      default:
        title = 'Empate';
        subtitle = 'Nadie se llevó la partida. Igualdad total.';
        icon = Icons.drag_handle;
        background = Court.c50;
        iconColor = Court.c800;
    }
    final onHeader = win ? Colors.white : Court.ink; // texto principal
    final soft = win ? Colors.white.withValues(alpha: 0.75) : Court.muted;

    return Container(
      color: background,
      child: Stack(
        children: [
          if (win) const CourtLines(opacity: 0.1),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: win ? Court.ball : Colors.white,
                      shape: BoxShape.circle,
                      border: win ? null : Border.all(color: Court.line),
                    ),
                    child: Icon(icon, size: 38, color: iconColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: display(
                      36,
                      weight: FontWeight.w900,
                      color: onHeader,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: body(14, color: soft),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _score(
                        'Tú',
                        m.playerScore,
                        win ? Court.ball : Court.muted,
                        onHeader,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '–',
                          style: display(
                            28,
                            color: onHeader.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      _score('CPU', m.opponentScore, soft, onHeader),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _score(String label, int value, Color labelColor, Color color) =>
      Column(
        children: [
          Text(
            label,
            style: body(12, weight: FontWeight.w600, color: labelColor),
          ),
          Text('$value', style: display(44, color: color, height: 1)),
        ],
      );
```

- Un `switch` sobre `outcome` elige título, texto, ícono y colores. **El empate se diferencia** de la victoria y de la derrota.
- Las variables `final String title;` se declaran sin valor y el `switch` les da uno en cada caso. Dart revisa que ninguna quede sin asignar.
- Solo la victoria lleva fondo verde oscuro y líneas de cancha.

📄 **`app_flutter/lib/presentation/result_page.dart`** · parte 4 de 5 (líneas 194–240) · sigue debajo de la parte anterior

```dart
  // --- Resumen, guardado y botones ---

  Widget _summary(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen de rondas', style: display(16, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (var i = 0; i < m.results.length; i++) _roundRow(i, m.results[i]),
        DemoTag(demo: widget.app.isDemo),
        const SizedBox(height: 12),
        if (saving) const LinearProgressIndicator(),
        if (saved)
          Text('Resultado guardado', style: body(12, color: Court.muted)),
        if (saveError != null) ...[
          Text(saveError!, style: body(13, color: Court.loss)),
          const SizedBox(height: 8),
          CourtButton(
            'Reintentar guardado',
            variant: ButtonVariant.secondary,
            onPressed: saving ? null : record,
          ),
        ],
        const SizedBox(height: 20),
        CourtButton(
          'Volver a jugar',
          variant: ButtonVariant.accent,
          size: ButtonSize.lg,
          icon: Icons.refresh,
          full: true,
          // Solo cuando ya se guardó: si no, esta partida podría perderse.
          onPressed: saving || !saved ? null : playAgain,
        ),
        const SizedBox(height: 8),
        CourtButton(
          'Ir al inicio',
          variant: ButtonVariant.secondary,
          size: ButtonSize.lg,
          icon: Icons.home_outlined,
          full: true,
          onPressed: saving ? null : () => goToTab(context, Tabs.home),
        ),
        const SizedBox(height: 32),
      ],
    ),
  );
```

- «Volver a jugar» se activa **solo** cuando ya se guardó. Si no, esta partida podría perderse.
- «Ir al inicio» usa `goToTab`: cierra Resultado y muestra la pestaña Inicio.

📄 **`app_flutter/lib/presentation/result_page.dart`** · parte 5 de 5 (líneas 242–320) · sigue debajo de la parte anterior

```dart
  // --- Una fila del resumen ---

  /// Una fila del resumen: ronda, atributo, valores y quién ganó.
  Widget _roundRow(int i, RoundResult r) {
    final (String label, Color bg, Color fg) = switch (r.outcome) {
      1 => ('Ganada', Court.ball, Court.c900),
      0 => ('Empate', Court.c50, Court.c800),
      _ => ('Perdida', Court.locked, Court.muted),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Court.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ronda ${i + 1} · ${r.challenge.label}',
                  style: body(12, weight: FontWeight.w600, color: Court.muted),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  label,
                  style: body(11.5, weight: FontWeight.w700, color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  r.player.lastName,
                  overflow: TextOverflow.ellipsis,
                  style: body(
                    14,
                    weight: r.outcome == 1 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(formatStat(r.player, r.challenge), style: display(14)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('vs', style: body(12, color: Court.muted)),
              ),
              Text(formatStat(r.opponent, r.challenge), style: display(14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.opponent.lastName,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: body(
                    14,
                    weight: r.outcome == -1 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- Cada fila muestra la ronda, el atributo, los dos valores (con `formatStat`, de Emma) y una etiqueta Ganada, Empate o Perdida.
- El apellido del ganador va en negrita.

## Paso 4 · Conectar Partida con Resultado

En `lib/presentation/match_page.dart` (de Sebastián: avísale) hay un `PROVISIONAL`. Agrega los dos imports, en orden alfabético con los otros:

```dart
import 'navigation.dart';
import 'result_page.dart';
```

Y cambia el principio de `next()`:

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

- `replace: true` usa `pushReplacement`: Resultado **reemplaza** a Partida. Al volver no se llega a una partida terminada, y «Volver a jugar» reemplaza Resultado por una partida nueva.

```bash
dart format lib && flutter analyze && flutter test
flutter run -d linux     # juega una partida completa: debe terminar en Resultado
git add -A && git commit -m "Pantalla Resultado que guarda la partida"
git push -u origin miguel/dia3-resultado && gh pr create --fill
```

📣 Avisa a Sebastián: «Resultado en PR, toca `match_page.dart` solo en `next()` y los imports».

Cuando el Inicio de Emma esté integrado, juega una partida y entra al Perfil desde el avatar: Partidas y Victorias deben sumar.

## Cierre del día

- [ ] Dos PR: Perfil (antes de las 12:00) y Resultado con el cambio en `next()`.
- [ ] Sabes explicar `addPostFrameCallback`, `PopScope` y `errorText`.
- [ ] En el dispositivo de Sebastián: el reinicio conserva las partidas y el apodo (escenario 6).
- [ ] Check-in de las 21:00.
