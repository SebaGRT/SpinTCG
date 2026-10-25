import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spintcg/application/app_controller.dart';
import 'package:spintcg/data/catalog_repository.dart';
import 'package:spintcg/data/local_store.dart';
import 'package:spintcg/domain/saved_team.dart';
import 'package:spintcg/presentation/app_shell.dart';
import 'package:spintcg/presentation/errores.dart';
import 'package:spintcg/presentation/validadores.dart';
import 'package:spintcg/presentation/widgets/player_card.dart';
import 'package:spintcg/presentation/widgets/team_name_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Validadores, filas y errores (sin pantalla) ---

void main() {
  test('Validadores del ingreso y del nombre de equipo', () {
    expect(validarCorreo(''), 'Escribe tu correo');
    expect(validarCorreo('emma@'), 'Ese correo no es válido');
    expect(validarCorreo(' emma@udd.cl '), isNull);
    expect(validarClave('12345'), 'Usa al menos 6 caracteres');
    expect(validarClave('123456'), isNull);
    expect(validarNombreEquipo('   '), 'Ponle un nombre al equipo');
    expect(validarNombreEquipo('x' * 25), 'Usa hasta 24 caracteres');
    expect(validarNombreEquipo(' Arcilla '), isNull);
  });

  test('Una fila de Supabase se convierte en SavedTeam', () {
    final team = SavedTeam.fromJson({
      'id': 7,
      'user_id': '6f1c0d9e-0000-4000-8000-000000000000',
      'nombre': 'Arcilla',
      'cartas': ['atp-1', 'atp-2', 'atp-3'],
      'creado': '2026-10-24T15:30:00.123456+00:00',
    });
    expect(team.id, 7);
    expect(team.name, 'Arcilla');
    expect(team.cards, ['atp-1', 'atp-2', 'atp-3']);
    expect(team.created.toUtc().hour, 15);
  });

  test('Los errores de Supabase se muestran en español', () {
    expect(
      mensajeDeError(
        const AuthException('Invalid login', code: 'invalid_credentials'),
      ),
      'Correo o contraseña incorrectos',
    );
    expect(
      mensajeDeError(const PostgrestException(message: 'denied')),
      'No se pudo guardar en tu cuenta. Inténtalo de nuevo.',
    );
  });

  // --- Formulario del nombre de equipo ---

  testWidgets('El diálogo valida el nombre antes de cerrarse', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await askTeamName(context, title: 'Guardar equipo'),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Vacío: el validador muestra el error y el diálogo sigue abierto.
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Ponle un nombre al equipo'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  Arcilla ');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(result, 'Arcilla');
    expect(find.byType(AlertDialog), findsNothing);
  });

  // --- Hero y FutureBuilder en la app ---

  testWidgets('Hero de Colección a Detalle y ranking con FutureBuilder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = AppController(
      CatalogRepository(''),
      MemoryLocalStore(),
      random: Random(1),
    );
    await app.load();
    await tester.pumpWidget(CourtApp(app: app));

    // La carta vuela de la grilla al Detalle sin desbordes.
    await tester.tap(find.text('Colección').last);
    await tester.pumpAndSettle();
    expect(find.byType(Hero), findsWidgets);
    final card = find.byWidgetPredicate(
      (w) => w is PlayerCard && w.card.id == app.owned.first.id,
    );
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pump(const Duration(milliseconds: 150)); // a mitad del vuelo
    await tester.pumpAndSettle();
    expect(find.text('Detalle de carta'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();

    // Perfil → Ranking ATP: primero espera, después la lista.
    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Ranking ATP'), 200);
    await tester.tap(find.text('Ranking ATP'));
    // Primer cuadro: el Future aún no termina. (La pantalla nueva se arma
    // fuera de escena antes de entrar; por eso skipOffstage: false).
    await tester.pump();
    expect(
      find.byType(CircularProgressIndicator, skipOffstage: false),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.text('#1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    app.dispose();
  });
}
