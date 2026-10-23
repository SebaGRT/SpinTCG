import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/court_button.dart';

/// PROVISIONAL, REEMPLAZA CUANDO PUEDAS EMMA

class HomePage extends StatelessWidget {
  final AppController app;
  const HomePage({super.key, required this.app});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(kBrand, style: display(22)),
      const SizedBox(height: 16),
      Text('Hola, ${app.nickname}', style: body(14, color: Court.muted)),
      Text(
        '${app.uniqueCount} de ${app.catalog.length} cartas únicas',
        style: display(24),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: app.uniqueCount / app.catalog.length),
      const SizedBox(height: 24),
      CourtButton(
        'Jugar partida',
        variant: ButtonVariant.accent,
        size: ButtonSize.lg,
        full: true,
        onPressed: () => goToTab(context, Tabs.play),
      ),
      const SizedBox(height: 8),
      CourtButton(
        app.canOpenPack
            ? 'Abrir sobre diario'
            : 'Sobre abierto * mañana hay otro',
        variant: ButtonVariant.secondary,
        full: true,
        onPressed: () => goToTab(context, Tabs.packs),
      ),
      const SizedBox(height: 8),
      CourtButton(
        'Coleccion',
        variant: ButtonVariant.secondary,
        full: true,
        onPressed: () => goToTab(context, Tabs.collection),
      ),
    ],
  );
}
