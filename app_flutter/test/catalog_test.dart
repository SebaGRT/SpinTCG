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
