<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Sebastián · Día 4 (sábado 24): prueba de interfaz, APK y congelamiento

**Meta del día:** una prueba de interfaz que recorre la app completa; a las **18:00** se congela el código; APK y README listos; ensayo general a las **21:00**.

← [Día 3](dia3.md) · [Índice](../README.md)

## Mapa del día

| Paso | Qué haces | Archivo | Antes de |
|---|---|---|---|
| 1 | Prueba de interfaz del flujo completo | `test/ui_flow_test.dart` | |
| 2 | Integrar lo último y congelar | — | **18:00** |
| 3 | APK y README | `README.md` | |
| 4 | Ensayo general | — | 21:00 |

---

## Paso 1 · Prueba de interfaz (rama `sebastian/dia4-prueba-ui`)

**Crea** `test/ui_flow_test.dart` en 3 partes.

📄 **`app_flutter/test/ui_flow_test.dart`** · parte 1 de 3 (líneas 1–35) · empieza el archivo

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/application/app_controller.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/local_store.dart';
import 'package:spintcg/presentation/app_shell.dart';

// --- Ayudantes ---

/// Pantalla de un teléfono común (390 × 844) y un controlador con datos demo.
Future<AppController> abrirApp(WidgetTester tester, {int seed = 1}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final app = AppController(
    CatalogRepository(''),
    MemoryLocalStore(),
    random: Random(seed),
  );
  await app.load();
  await tester.pumpWidget(CourtApp(app: app));
  return app;
}

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
```

- `abrirApp()` simula un teléfono (`tester.view.physicalSize = Size(390, 844)`) con datos demo en memoria. Si algo no cabe, Flutter lanza un error de *overflow* y la prueba falla: así detectamos textos que desbordan.
- `tocar()` hace `ensureVisible` antes de tocar: desplaza la lista hasta que el elemento esté a la vista, como haría una persona.

📄 **`app_flutter/test/ui_flow_test.dart`** · parte 2 de 3 (líneas 37–68) · sigue debajo de la parte anterior

```dart
  // --- Prueba 1: Inicio, colección y perfil ---

  testWidgets('Inicio, colección y perfil sin desbordes en móvil', (
    tester,
  ) async {
    final app = await abrirApp(tester);
    expect(find.text('Hola, Tenista'), findsOneWidget);

    await tocar(tester, find.text('Colección').last);
    expect(find.text('Elegir equipo'), findsOneWidget);
    expect(find.text('Buscar por nombre'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tocar(tester, find.text('Inicio').last);
    await tocar(tester, find.byTooltip('Perfil'));
    await tocar(tester, find.byTooltip('Editar apodo'));

    // Apodo vacío: el error aparece dentro del campo y no se guarda.
    await tester.enterText(find.byType(TextField), '   ');
    await tocar(tester, find.text('Guardar'));
    expect(find.text('Usa un apodo de 1 a 16 caracteres'), findsOneWidget);
    expect(app.nickname, 'Tenista');

    await tester.enterText(find.byType(TextField), 'Emma');
    await tocar(tester, find.text('Guardar'));
    expect(app.nickname, 'Emma');
    expect(find.text('Emma'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });
```

- `hitTestWarningShouldBeFatal = true`: si un toque cae sobre algo tapado o fuera de la pantalla, la prueba falla en lugar de solo advertir.
- Revisa la validación del apodo: con espacios, el error aparece **dentro del campo** y no se guarda.

📄 **`app_flutter/test/ui_flow_test.dart`** · parte 3 de 3 (líneas 70–127) · sigue debajo de la parte anterior

```dart
  // --- Prueba 2: equipo, sobre y partida ---

  testWidgets('Equipo, sobre revelado y partida guardada desde la interfaz', (
    tester,
  ) async {
    final app = await abrirApp(tester, seed: 4);

    // 1. Elegir equipo desde Colección.
    await tocar(tester, find.text('Colección').last);
    await tocar(tester, find.text('Elegir equipo'));
    final team = app.owned.take(3).toList();
    for (final card in team) {
      await tocar(tester, find.text(card.name));
    }
    expect(find.text('3 de 3 seleccionadas'), findsOneWidget);
    await tocar(tester, find.text('Guardar equipo'));
    expect(app.team.length, 3);
    // Guardar equipo lleva a la pestaña Jugar.
    expect(find.text('Cómo se juega'), findsOneWidget);

    // 2. Abrir y revelar el sobre diario.
    await tocar(tester, find.text('Sobres').last);
    await tocar(tester, find.text('Abrir sobre'));
    expect(app.copies.values.reduce((a, b) => a + b), 9);
    for (var i = 1; i <= 3; i++) {
      await tocar(tester, find.bySemanticsLabel(RegExp('^Revelar carta $i')));
      expect(find.text('$i de 3 reveladas'), findsOneWidget);
    }
    expect(find.text('Cartas añadidas a tu colección'), findsOneWidget);
    await tocar(tester, find.text('Ver colección'));
    await tocar(tester, find.text('Sobres').last);
    expect(find.text('Sobre de hoy abierto'), findsOneWidget);

    // 3. Jugar tres rondas.
    await tocar(tester, find.text('Jugar').last);
    // El botón queda bajo la lista: se desplaza hasta que se construya.
    await tester.scrollUntilVisible(find.text('Iniciar partida'), 200);
    await tocar(tester, find.text('Iniciar partida'));
    expect(find.text('Ronda 1 de 3'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tocar(tester, find.byKey(ValueKey('mano-${team[i].id}')));
      await tocar(tester, find.text('Confirmar elección'));
      await tocar(
        tester,
        find.text(i == 2 ? 'Ver resultado' : 'Siguiente ronda'),
      );
    }

    // 4. Resultado guardado en el progreso.
    expect(app.played, 1);
    await tester.scrollUntilVisible(find.text('Resultado guardado'), 200);
    expect(find.text('Resumen de rondas'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });
}
```

- Recorre la app como un usuario: elegir equipo, abrir el sobre, revelar las 3 cartas y jugar las 3 rondas.
- `find.bySemanticsLabel(RegExp('^Revelar carta 1'))`: la carta boca abajo tiene la etiqueta «Revelar carta 1», combinada con el texto del reverso. Por eso se busca con una expresión regular que **empieza** así.
- `scrollUntilVisible` es para las listas *perezosas* (`ListView`), que solo construyen lo que está cerca de la pantalla. «Iniciar partida» y «Resultado guardado» no existen hasta que se desplaza la lista.
- `find.byKey(ValueKey('mano-…'))`: las cartas de la mano se tocan por el id, porque el apellido también aparece en la carta grande del duelo.

```bash
dart format test && flutter analyze && flutter test     # 15 pruebas con las de Miguel
git add -A && git commit -m "Prueba de interfaz del flujo completo con el diseño nuevo"
```

## Paso 2 · Congelamiento (18:00)

- [ ] Integrar lo último de Emma (ajustes de QA) y de Miguel (pruebas propias).
- [ ] `flutter analyze`, `flutter test` y `node --test adapter.test.mjs` en verde.
- [ ] Después de las 18:00 **solo se corrigen errores**.

## Paso 3 · APK y README

Los comandos de la APK y el contenido del README están en la sección del sábado de [`../../plan-crunch/sebastian.md`](../../plan-crunch/sebastian.md). Agrega al README:

- Capturas de Emma (`docs/evidencia/capturas/`).
- Las diferencias declaradas con el mockup (sección final del [índice de guías](../README.md)).
- Quién hizo qué, archivo por archivo (tabla «Quién es dueño de cada archivo» del índice).

## Paso 4 · Ensayo general (21:00)

El recorrido de 2 minutos de [`../../kit/03-arranque-emergencia.md`](../../kit/03-arranque-emergencia.md), en el dispositivo de la presentación.

**Tu explicación:** arquitectura (`AppController` y `_change()`), servidor intermediario (por qué la clave no va en la app), navegación con `TabScope` y `openPage`, y cómo verificamos con pruebas.
