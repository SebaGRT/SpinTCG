import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/application/app_controller.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/local_store.dart';
import 'package:spintcg/presentation/app_shell.dart';

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
