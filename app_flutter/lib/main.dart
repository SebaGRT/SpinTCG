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
  final controller = AppController(
    CatalogRepository(baseUrl),
    FileLocalStore(baseUrl.isEmpty ? 'demo' : 'rapidapi'),
  );

  if (cloudEnabled) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
    final db = Supabase.instance.client;
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider(create: (_) => SessionController(db.auth)),
          Provider(create: (_) => TeamsRepository(db)),
        ],
        child: AuthGate(app: controller),
      ),
    );
  } else {
    runApp(CourtApp(app: controller));
  }
  await controller.load();
}
