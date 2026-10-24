<!-- Archivo generado por scripts/guias/generar.py: edita la plantilla, no este archivo. -->
# Miguel · Día 4 (sábado 24): pruebas propias, escenarios y evidencia

**Meta del día:** las pruebas automáticas del núcleo (reglas de la partida, progreso, equipo, rival y apodo), los 10 escenarios recorridos en la versión integrada y la evidencia lista **antes de las 18:00**.

← [Día 3](dia3.md) · [Índice](../README.md)

## Mapa del día

| Paso | Qué haces | Archivo | Antes de |
|---|---|---|---|
| 1 | Pruebas de las reglas | `test/game_test.dart` | |
| 1 | Pruebas del progreso | `test/progress_test.dart` | |
| 1 | Pruebas de equipo, rival y apodo | `test/equipo_y_apodo_test.dart` | |
| 2 | Recorrer los 10 escenarios | `docs/escenarios-prueba.md` | **18:00** (reportar ✗) |
| 3 | Evidencia | `docs/evidencia/miguel.md` | |
| 4 | Ensayo general | — | 21:00 |

[Cómo leer los bloques de código](../README.md#cómo-leer-los-bloques-de-código).

---

## Paso 1 · Pruebas propias (rama `miguel/dia4-pruebas`)

```bash
git switch main && git pull && git switch -c miguel/dia4-pruebas
cd app_flutter
```

### Reglas de la partida

Crea `test/game_test.dart`:

📄 **`app_flutter/test/game_test.dart`** · 58 líneas

```dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/domain/game.dart';
import 'package:spintcg/domain/tennis_card.dart';
import 'package:spintcg/data/demo_catalog.dart';

void main() {
  test(
    'Ranking menor gana; títulos y porcentaje mayores ganan; igualdad empata',
    () {
      const a = TennisCard(
        id: 'a',
        name: 'A',
        country: 'CHI',
        ranking: 1,
        titles: 4,
        winRate: 75,
      );
      const b = TennisCard(
        id: 'b',
        name: 'B',
        country: 'CHI',
        ranking: 2,
        titles: 3,
        winRate: 60,
      );
      for (final challenge in Challenge.values) {
        expect(compareCards(a, b, challenge), 1);
        expect(compareCards(b, a, challenge), -1);
        expect(compareCards(a, a, challenge), 0);
      }
    },
  );
  test('Tres rondas, sin reutilización y sin cuarta ronda', () {
    final cards = demoCatalog();
    final m = MatchSession(
      cards.take(3).toList(),
      cards.skip(3).take(3).toList(),
      random: Random(1),
    );
    for (final c in cards.take(3)) {
      m.play(c.id);
      expect(() => m.play(c.id), throwsA(anything));
    }
    expect(m.finished, true);
    expect(m.remaining, isEmpty);
    expect(m.results.map((r) => r.opponent.id).toSet().length, 3);
    expect(() => m.play(cards[3].id), throwsStateError);
  });
  test('Equipo duplicado rechazado', () {
    final cards = demoCatalog();
    expect(
      () =>
          MatchSession([cards[0], cards[0], cards[2]], cards.take(3).toList()),
      throwsArgumentError,
    );
  });
}
```

**Entiende**
- Cartas armadas a mano (`const TennisCard(...)`) con valores elegidos para que el resultado sea obvio: así se prueba cada regla (ranking menor gana, títulos y % mayor ganan, igualdad empata).
- `Random(1)` hace que el rival salga siempre igual: la prueba no depende de la suerte.
- También revisa los errores: equipos con cartas repetidas, usar una carta dos veces o jugar una cuarta ronda.

### Progreso guardado

Crea `test/progress_test.dart`:

📄 **`app_flutter/test/progress_test.dart`** · 97 líneas

```dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/application/app_controller.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/local_store.dart';

class FailingStore extends MemoryLocalStore {
  bool fail = false;
  @override
  Future<void> write(Map<String, dynamic> value) async {
    if (fail) throw StateError('Disco no disponible');
    await super.write(value);
  }
}

void main() {
  test(
    'Seis cartas únicas iniciales, tres por sobre y un sobre por día',
    () async {
      var time = DateTime(2026, 10, 12, 10);
      final store = MemoryLocalStore();
      final a = AppController(
        CatalogRepository(''),
        store,
        random: Random(2),
        now: () => time,
      );
      await a.load();
      expect(a.uniqueCount, 6);
      final pack = await a.openPack();
      expect(pack.length, 3);
      expect(a.copies.values.reduce((x, y) => x + y), 9);
      expect(a.canOpenPack, false);
      await expectLater(a.openPack(), throwsStateError);
      time = DateTime(2026, 10, 13);
      expect(a.canOpenPack, true);
      time = DateTime(2026, 10, 11);
      expect(a.canOpenPack, false);
      final b = AppController(
        CatalogRepository(''),
        store,
        now: () => DateTime(2026, 10, 12),
      );
      await b.load();
      expect(b.copies, a.copies);
      expect(b.canOpenPack, false);
      a.dispose();
      b.dispose();
    },
  );
  test(
    'Equipo y apodo persisten; límite tres cartas; resultado no se duplica',
    () async {
      final store = MemoryLocalStore();
      final a = AppController(CatalogRepository(''), store, random: Random(1));
      await a.load();
      for (final c in a.owned.take(3)) {
        await a.toggleTeam(c.id);
      }
      await expectLater(a.toggleTeam(a.owned[3].id), throwsStateError);
      expect(a.team.length, 3);
      await a.saveNickname('Sebastián');
      final match = a.startMatch();
      for (final c in a.selected) {
        match.play(c.id);
      }
      await a.recordMatch(match);
      await a.recordMatch(match);
      expect(a.played, 1);
      final b = AppController(CatalogRepository(''), store);
      await b.load();
      expect(b.team, a.team);
      expect(b.nickname, 'Sebastián');
      expect(b.played, 1);
      a.dispose();
      b.dispose();
    },
  );
  test(
    'Si falla el guardado, un sobre no deja cartas ni cooldown en memoria',
    () async {
      final store = FailingStore();
      final a = AppController(CatalogRepository(''), store, random: Random(3));
      await a.load();
      final before = Map<String, int>.of(a.copies);
      store.fail = true;
      await expectLater(a.openPack(), throwsStateError);
      expect(a.copies, before);
      expect(a.lastPackDay, isNull);
      expect(a.canOpenPack, true);
      store.fail = false;
      await a.openPack();
      expect(a.canOpenPack, false);
      a.dispose();
    },
  );
}
```

**Entiende**: estas pruebas vigilan el `_change()` de Sebastián.
- `now: () => time` fija la fecha: se puede «adelantar un día» cambiando `time`, sin esperar 24 horas.
- Dos controladores con el **mismo** `MemoryLocalStore` simulan cerrar y reabrir la app: lo que guardó el primero lo lee el segundo.
- `FailingStore` es un almacenamiento que falla a propósito. Si el disco falla al abrir un sobre, las cartas **no** deben quedar sumadas en memoria y el sobre debe seguir disponible.

```bash
dart format test && flutter analyze && flutter test     # 9 pruebas en verde
git add -A && git commit -m "Pruebas de reglas y progreso"
```

### Equipo, rival y apodo

Crea `test/equipo_y_apodo_test.dart`:

📄 **`app_flutter/test/equipo_y_apodo_test.dart`** · 60 líneas

```dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/application/app_controller.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/local_store.dart';

/// Controlador con el catálogo demo y el progreso en memoria.
Future<AppController> nuevaApp({int seed = 2}) async {
  final app = AppController(
    CatalogRepository(''),
    MemoryLocalStore(),
    random: Random(seed),
  );
  await app.load();
  return app;
}

void main() {
  test(
    'Guardar equipo: acepta 3 obtenidas y rechaza una no obtenida',
    () async {
      final app = await nuevaApp();
      final ids = app.owned.take(3).map((c) => c.id).toList();
      await app.saveTeam(ids);
      expect(app.team, ids);

      final noObtenida = app.catalog.firstWhere(
        (c) => (app.copies[c.id] ?? 0) == 0,
      );
      await expectLater(app.saveTeam([noObtenida.id]), throwsArgumentError);
      expect(app.team, ids, reason: 'un error no debe cambiar el equipo');
    },
  );

  test('Guardar equipo rechaza tenistas repetidos', () async {
    final app = await nuevaApp();
    final id = app.owned.first.id;
    await expectLater(app.saveTeam([id, id]), throwsArgumentError);
    expect(app.team, isEmpty);
  });

  test('El rival nunca usa tenistas de tu equipo', () async {
    for (var seed = 0; seed < 20; seed++) {
      final app = await nuevaApp(seed: seed);
      await app.saveTeam(app.owned.take(3).map((c) => c.id).toList());
      final match = app.startMatch();
      for (final rival in match.opponents) {
        expect(app.team, isNot(contains(rival.id)));
      }
    }
  });

  test('Apodo: máximo 16 caracteres y se guarda sin espacios extra', () async {
    final app = await nuevaApp();
    await expectLater(app.saveNickname('A' * 17), throwsArgumentError);
    expect(app.nickname, 'Tenista');
    await app.saveNickname('  ${'B' * 16}  ');
    expect(app.nickname, 'B' * 16);
  });
}
```

**Entiende**
- Prueban el **controlador**, no la interfaz: son rápidas y no dependen de textos.
- `expectLater(..., throwsArgumentError)` espera que el `Future` falle con ese tipo de error.
- La primera prueba revisa algo importante de `_change()`: **un error no cambia el estado** (el equipo sigue igual).
- La del rival repite con 20 semillas (`Random(seed)`) porque el rival es aleatorio: una sola partida podría pasar por suerte.
- `'A' * 17` crea un texto de 17 letras. El apodo con espacios alrededor se guarda recortado (`trim()`).

```bash
dart format test && flutter analyze && flutter test     # 13 pruebas (15 cuando Sebastián suba la de interfaz)
git add -A && git commit -m "Pruebas de equipo, rival y apodo"
git push -u origin miguel/dia4-pruebas && gh pr create --fill
```

**Haz el experimento:** en `app_controller.dart` cambia temporalmente `> 16` por `> 20` y vuelve a ejecutar las pruebas. La del apodo debe fallar. Deshaz el cambio. Así compruebas que la prueba de verdad vigila la regla.

## Paso 2 · Escenarios en la versión integrada

Con el `main` del sábado (idealmente la APK en el dispositivo de la presentación), recorre los 10 escenarios de `docs/escenarios-prueba.md` y marca ✓ o ✗ con una captura.

Para el escenario 7 (fecha del dispositivo): en Android, Ajustes → Sistema → Fecha y hora → desactiva la hora automática.

**Reporta cada ✗ en el chat antes de las 18:00.** Después de esa hora solo se corrigen errores bloqueantes.

## Paso 3 · Evidencia

`docs/evidencia/miguel.md`, con la plantilla de [`../../evidencia/README.md`](../../evidencia/README.md):

- Fecha, dispositivo y versión.
- Tabla de escenarios con ✓/✗ y el enlace a cada captura.
- Las pruebas que escribiste y qué regla protege cada una.
- Limitaciones conocidas (por ejemplo, si adelantas la fecha del teléfono se habilita el sobre).

## Paso 4 · Ensayo (21:00)

**Tu explicación (2 min):** cómo se abre un sobre (aleatorio con repetición, uno por día local, nueva o duplicada), cómo se guarda una partida (Resultado → `recordMatch` → `_change()`), dónde vive el progreso (JSON en la carpeta privada de la app) y cómo lo verificaste (pruebas y escenarios).
