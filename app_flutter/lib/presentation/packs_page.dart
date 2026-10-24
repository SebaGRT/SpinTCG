import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'errores.dart';
import 'navigation.dart';
import 'reveal_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/pack_art.dart';

// --- Abrir el sobre ---

class PacksPage extends StatelessWidget {
  final AppController app;
  const PacksPage({super.key, required this.app});

  Future<void> _open(BuildContext context) async {
    // Copias antes de abrir, para saber si cada carta es nueva o duplicada.
    final before = Map<String, int>.of(app.copies);
    try {
      final cards = await app.openPack();
      final revealed = <PackCard>[];
      for (final card in cards) {
        final copies = (before[card.id] ?? 0) + 1;
        revealed.add(PackCard(card, isNew: copies == 1, copies: copies));
        before[card.id] = copies;
      }
      if (context.mounted) {
        await openPage(
          context,
          app,
          () => RevealPage(app: app, cards: revealed),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }

  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final opened = !app.canOpenPack;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const ScreenTitle(
                'Sobres',
                subtitle: 'Un sobre gratuito cada día',
              ),
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _ring(320, Court.c100),
                    _ring(256, Court.c200),
                    PackArt(width: 190, opened: opened),
                    if (opened) _openedChip(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                opened ? 'Sobre de hoy abierto' : 'Sobre diario',
                style: display(24),
              ),
              const SizedBox(height: 6),
              opened
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 17,
                          color: Court.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Disponible mañana',
                          style: body(15, color: Court.muted),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: 260,
                      child: Text(
                        'Obtén tres cartas aleatorias para tu colección',
                        textAlign: TextAlign.center,
                        style: body(15, color: Court.muted),
                      ),
                    ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _tag('3 cartas'),
                    _tag('Gratis cada día'),
                    _tag('Las repetidas suman copias'),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: opened
                    ? Column(
                        children: [
                          const CourtButton(
                            'Disponible mañana',
                            size: ButtonSize.lg,
                            icon: Icons.schedule,
                            full: true,
                          ),
                          const SizedBox(height: 8),
                          CourtButton(
                            'Ver colección',
                            variant: ButtonVariant.ghost,
                            full: true,
                            onPressed: () => goToTab(context, Tabs.collection),
                          ),
                        ],
                      )
                    : CourtButton(
                        'Abrir sobre',
                        variant: ButtonVariant.accent,
                        size: ButtonSize.lg,
                        icon: Icons.inventory_2_outlined,
                        full: true,
                        onPressed: app.busy ? null : () => _open(context),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Piezas pequeñas ---

  Widget _ring(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color),
    ),
  );

  Widget _openedChip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: Court.line),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 16, color: Court.c800),
        const SizedBox(width: 6),
        Text(
          'Abierto',
          style: body(13, weight: FontWeight.w700, color: Court.c800),
        ),
      ],
    ),
  );

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Court.c50,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: Court.c100),
    ),
    child: Text(
      text,
      style: body(12, weight: FontWeight.w500, color: Court.c800),
    ),
  );
}
