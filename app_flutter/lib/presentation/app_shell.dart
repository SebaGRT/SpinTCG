import 'package:flutter/material.dart';
import 'package:spintcg/presentation/packs_page.dart';
import '../application/app_controller.dart';
import 'collection_page.dart';
import 'home_page.dart';
import 'navigation.dart';
import 'play_page.dart';
import 'theme.dart';
import 'widgets/court_button.dart';

class CourtApp extends StatefulWidget {
  final AppController app;
  const CourtApp({super.key, required this.app});
  @override
  State<CourtApp> createState() => _CourtAppState();
}

class _CourtAppState extends State<CourtApp> {
  final tab = ValueNotifier<int>(Tabs.home);

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: kBrand,
    theme: buildTheme(),
    debugShowCheckedModeBanner: false,
    builder: (context, child) => TabScope(tab: tab, child: child!),
    home: AppShell(app: widget.app, tab: tab),
  );
}

class AppShell extends StatelessWidget {
  final AppController app;
  final ValueNotifier<int> tab;
  const AppShell({super.key, required this.app, required this.tab});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([app, tab]),
    builder: (context, _) {
      if (app.loading) return const _LoadingView();
      if (app.error != null) {
        return _ErrorView(message: app.error!, onRetry: app.load);
      }
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab.value,
            children: [
              HomePage(app: app),
              CollectionPage(app: app),
              PacksPage(app: app),
              PlayPage(app: app),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          selected: tab.value,
          packDot: app.canOpenPack,
          onSelect: (value) => tab.value = value,
        ),
      );
    },
  );
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final bool packDot;
  final ValueChanged<int> onSelect;
  const _BottomNav({
    required this.selected,
    required this.packDot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Court.line)),
    ),
    child: NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Court.c800,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 21,
            color: states.contains(WidgetState.selected)
                ? Court.ball
                : Court.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? body(11.5, weight: FontWeight.w700, color: Court.c900)
              : body(11.5, weight: FontWeight.w500, color: Court.muted),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: onSelect,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.style_outlined),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.style_outlined),
            label: 'Colección',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: packDot,
              smallSize: 8,
              backgroundColor: Court.loss,
              child: const Icon(Icons.inventory_2_outlined),
            ),
            label: 'Sobres',
          ),
          const NavigationDestination(
            icon: Icon(Icons.sports_baseball_outlined),
            label: 'Jugar',
          ),
        ],
      ),
    ),
  );
}

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Court.c800,
      borderRadius: BorderRadius.circular(size / 3),
    ),
    child: Icon(
      Icons.sports_baseball_outlined,
      color: Court.ball,
      size: size * 0.56,
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandLogo(size: 64),
          const SizedBox(height: 20),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 12),
          Text('Cargando tenistas...', style: body(14, color: Court.muted)),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Court.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xfff6e3de),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Court.loss,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar los tenistas',
              textAlign: TextAlign.center,
              style: display(19, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Revisa tu conexión e inténtalo de nuevo. '
              'Tus cartas siguen guardadas en este dispositivo',
              textAlign: TextAlign.center,
              style: body(14, color: Court.muted),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: body(11, color: Court.disabledText),
            ),
            const SizedBox(height: 20),
            CourtButton('Reintentar', icon: Icons.refresh, onPressed: onRetry),
          ],
        ),
      ),
    ),
  );
}
