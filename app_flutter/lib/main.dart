import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'application/app_controller.dart';
import 'application/session_controller.dart';
import 'data/catalog_repository.dart';
import 'data/cloud.dart';
import 'data/local_store.dart';
import 'presentation/app_shell.dart';
import 'presentation/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  const mode = baseUrl == '' ? 'demo' : 'rapidapi';

  if (cloudEnabled) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
    final db = Supabase.instance.client;
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SessionController(db.auth)),
          Provider(create: (_) => TeamsRepository(db)),
        ],
        // Cada cuenta tiene su propio progreso: su propio archivo.
        child: AuthGate(
          controllerFor: (userId) => AppController(
            CatalogRepository(baseUrl),
            FileLocalStore('${mode}_$userId'),
          ),
        ),
      ),
    );
  } else {
    // Sin supabase.json: la app de siempre, sin cuenta (modo demo).
    final controller = AppController(
      CatalogRepository(baseUrl),
      FileLocalStore(mode),
    );
    runApp(CourtApp(app: controller));
    await controller.load();
  }
}
