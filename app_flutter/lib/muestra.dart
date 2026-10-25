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
