<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Emma · Día 4 (sábado 24): QA visual y capturas

**Meta del día:** revisar la app pantalla por pantalla contra el mockup, corregir lo que se pueda **antes de las 18:00** (congelamiento) y dejar las capturas en `docs/evidencia/capturas/`.

← [Día 3](dia3.md) · [Índice](../README.md)

## Mapa del día

| Paso | Qué haces | Archivo | Antes de |
|---|---|---|---|
| 1 | Recorrer cada pantalla contra el mockup | `docs/evidencia/qa-visual.md` | |
| 2 | Capturas automáticas (opcional) | `capturas/capturas_test.dart` | |
| 3 | Correcciones pequeñas | (las que encuentres) | **18:00** (congelamiento) |
| 4 | Ensayo general | — | 21:00 |

---

## Paso 1 · Recorrido en ancho de teléfono

En el teléfono o en el emulador (pídele a Sebastián el comando), o en Linux con la ventana angosta:

| Pantalla | Qué revisar contra el mockup |
|---|---|
| Inicio | Saludo, título según el sobre, tarjeta verde 6/24 con barra, botón verde limón, sobre con «Abrir sobre» o «Abierto», equipo o estado vacío |
| Colección | Título con «Elegir equipo», buscador, Todas/Duplicadas con conteo, grilla de 2 columnas, cartas bloqueadas grises |
| Detalle | «N.º 08/24», carta grande, cajas de estadísticas, copias, botón según el estado |
| Elegir equipo | 3 espacios, «N de 3 seleccionadas» con barritas, filas bloqueadas con 3 elegidos, botón fijo abajo |
| Sobres | Sobre con anillos, etiquetas, «Abrir sobre» / «Disponible mañana» |
| Revelación | Fondo verde oscuro, cartas 2 + 1, «Nueva» o «Duplicada · ×N», puntos de progreso |
| Jugar | Reglas, equipo con números, aviso si faltan tenistas |
| Partida | Ronda N de 3, marcador, banner del atributo, carta rival oculta → volteo, Gana/Empate/Pierde |
| Resultado | Victoria (verde), Derrota (gris) o Empate, resumen de las 3 rondas |
| Perfil | Avatar, apodo con lápiz, error dentro del campo, 3 cajas, «Cómo se juega» |

Busca en particular:
- Textos cortados o que desbordan (franja amarilla y negra en modo debug).
- Nombres largos: *Alejandro Davidovich Fokina*, *Félix Auger-Aliassime*.
- Botones que no hacen nada.

Anota cada diferencia en `docs/evidencia/qa-visual.md`, con la pantalla, la diferencia y si se corrigió o se declara.

## Paso 2 · Capturas automáticas (opcional, pero ahorra tiempo)

Esta prueba recorre la app y guarda una imagen de cada pantalla con las fuentes reales, a 390 × 844. Créala en `app_flutter/capturas/capturas_test.dart`:

📄 **`app_flutter/capturas/capturas_test.dart`** · 116 líneas

```dart
// Genera capturas PNG (390 × 844) de cada pantalla con las fuentes reales.
// Uso: flutter test capturas --update-goldens
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/application/app_controller.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/local_store.dart';
import 'package:spintcg/presentation/app_shell.dart';

Future<void> cargarFuentes() async {
  Future<ByteData> asset(String p) => rootBundle.load(p);
  final archivo = FontLoader('Archivo');
  for (final w in [500, 600, 700, 800, 900]) {
    archivo.addFont(asset('assets/fonts/Archivo-$w.ttf'));
  }
  final inter = FontLoader('Inter');
  for (final w in [400, 500, 600, 700]) {
    inter.addFont(asset('assets/fonts/Inter-$w.ttf'));
  }
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent;
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${sdk.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ).readAsBytes().then((b) => ByteData.sublistView(b)),
    );
  await Future.wait([archivo.load(), inter.load(), icons.load()]);
}

void main() {
  // Fuera de testWidgets: la E/S real no avanza con el reloj falso.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await cargarFuentes();
  });
  testWidgets('capturas', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final app = AppController(
      CatalogRepository(''),
      MemoryLocalStore(),
      random: Random(4),
    );
    await app.load();
    await tester.pumpWidget(CourtApp(app: app));
    await tester.pumpAndSettle();
    final shot = find.byType(CourtApp);
    Future<void> foto(String name) async {
      await tester.pumpAndSettle();
      await expectLater(shot, matchesGoldenFile('png/$name.png'));
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await foto('01-inicio-sin-equipo');
    await tap(find.text('Colección').last);
    await foto('02-coleccion');
    await tap(find.bySemanticsLabel(RegExp('^${app.owned.first.name}')).first);
    await foto('03-detalle');
    await tap(find.byTooltip('Volver'));
    await tester.scrollUntilVisible(
      find.text('Elegir equipo'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(find.text('Elegir equipo'));
    for (final c in app.owned.take(2)) {
      await tap(find.text(c.name));
    }
    await foto('04-equipo');
    await tap(find.text(app.owned[2].name));
    await tap(find.text('Guardar equipo'));
    await foto('05-jugar');
    await tap(find.text('Sobres').last);
    await foto('06-sobres');
    await tap(find.text('Abrir sobre'));
    await foto('07-revelar-0');
    await tap(find.bySemanticsLabel(RegExp('^Revelar carta 1')));
    await tap(find.bySemanticsLabel(RegExp('^Revelar carta 2')));
    await tap(find.bySemanticsLabel(RegExp('^Revelar carta 3')));
    await foto('08-revelar-3');
    await tap(find.text('Ver colección'));
    await tap(find.text('Inicio').last);
    await foto('09-inicio');
    await tap(find.byTooltip('Perfil'));
    await foto('10-perfil');
    await tap(find.byTooltip('Volver'));
    await tap(find.text('Jugar').last);
    await tester.scrollUntilVisible(find.text('Iniciar partida'), 200);
    await tap(find.text('Iniciar partida'));
    await foto('11-partida');
    final team = app.team;
    await tap(find.byKey(ValueKey('mano-${team[0]}')));
    await foto('12-partida-elegida');
    await tap(find.text('Confirmar elección'));
    await foto('13-partida-revelada');
    await tap(find.text('Siguiente ronda'));
    for (var i = 1; i < 3; i++) {
      await tap(find.byKey(ValueKey('mano-${team[i]}')));
      await tap(find.text('Confirmar elección'));
      await tap(find.text(i == 2 ? 'Ver resultado' : 'Siguiente ronda'));
    }
    await foto('14-resultado');
    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });
}
```

```bash
flutter test capturas --update-goldens          # crea capturas/png/*.png
mkdir -p ../docs/evidencia/capturas && cp capturas/png/*.png ../docs/evidencia/capturas/
```

**Entiende**
- `matchesGoldenFile` es la herramienta de Flutter para comparar pantallas con una imagen guardada. Con `--update-goldens` **guarda** la imagen en vez de comparar.
- Las pruebas usan una fuente de cuadritos por defecto. Por eso `cargarFuentes()` carga Archivo, Inter y los íconos antes de empezar.
- La carga va en `setUpAll` y no dentro de `testWidgets`, porque `testWidgets` usa un reloj falso y la lectura real de archivos nunca terminaría.
- La ruta de los íconos se calcula desde el ejecutable de prueba de Flutter. Está probado en Linux; en otro sistema operativo, si falla, usa capturas del teléfono.

Además, saca **al menos 3 capturas del teléfono real** (Inicio, Partida y Resultado): es la evidencia de que corre en Android.

## Paso 3 · Correcciones antes de las 18:00

Solo arreglos pequeños (espaciados, tamaños de letra, textos), cada uno en un commit:

```bash
git switch -c emma/dia4-qa
# … correcciones …
dart format lib && flutter analyze && flutter test
git add -A && git commit -m "QA visual: <qué>" && git push -u origin emma/dia4-qa && gh pr create --fill
```

Si cambias un texto visible, revisa `test/ui_flow_test.dart`: busca textos exactos.

## Paso 4 · Ensayo (21:00)

**Tu explicación (2 min):** la `PlayerCard` y sus tamaños, cómo una pantalla secundaria se redibuja (`openPage` + `ListenableBuilder`), los estados vacíos y de error, y las diferencias declaradas con el mockup.
