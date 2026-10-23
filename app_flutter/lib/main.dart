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
