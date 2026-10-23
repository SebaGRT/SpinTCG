import 'package:flutter/material.dart';
import 'application/app_controller.dart';
import 'data/catalog_repository.dart';
import 'data/local_store.dart';
import 'presentation/theme.dart';

// PROVISIONAL (miércoles en la tarde): carga el catálogo con el controlador
// real y lo guarda en el disco. El jueves se reemplaza por la app completa.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = AppController(CatalogRepository(''), FileLocalStore('demo'));
  await app.load();
  runApp(
    MaterialApp(
      title: kBrand,
      theme: buildTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${app.uniqueCount} de ${app.catalog.length} cartas'),
        ),
        body: ListView(
          children: [
            if (app.error != null) Text(app.error!),
            for (final card in app.owned)
              ListTile(
                title: Text(
                  card.name,
                  style: body(16, weight: FontWeight.w600),
                ),
                subtitle: Text(
                  '#${card.ranking} · ${card.titles} títulos · ${card.winRate}%',
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
