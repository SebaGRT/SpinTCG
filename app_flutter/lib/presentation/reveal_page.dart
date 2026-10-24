import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/card_back.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/flip_card.dart';
import 'widgets/player_card.dart';

/// Una carta del sobre: si es nueva y cuántas copias quedan.
class PackCard {
  final TennisCard card;
  final bool isNew;
  final int copies;
  const PackCard(this.card, {required this.isNew, required this.copies});
}

/// Pantalla oscura donde se revelan las tres cartas del sobre.
class RevealPage extends StatefulWidget {
  final AppController app;
  final List<PackCard> cards;
  const RevealPage({super.key, required this.app, required this.cards});
  @override
  State<RevealPage> createState() => _RevealPageState();
}

class _RevealPageState extends State<RevealPage> {
  final revealed = <int>{};

  @override
  Widget build(BuildContext context) {
    final done = revealed.length == widget.cards.length;
    return Scaffold(
      backgroundColor: Court.c900,
      body: Stack(
        children: [
          const CourtLines(opacity: 0.07),
          SafeArea(
            child: Column(
              children: [
                TopBar(
                  'Sobre diario',
                  dark: true,
                  onBack: () => Navigator.pop(context),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${revealed.length} de 3 reveladas',
                      style: body(
                        13,
                        weight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                Text(
                  done
                      ? 'Cartas añadidas a tu colección'
                      : 'Toca cada carta para revelarla',
                  style: body(14, color: Colors.white.withValues(alpha: 0.7)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _card(0),
                            const SizedBox(width: 16),
                            _card(1),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _card(2),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: done
                      ? CourtButton(
                          'Ver colección',
                          variant: ButtonVariant.accent,
                          size: ButtonSize.lg,
                          iconRight: Icons.chevron_right,
                          full: true,
                          onPressed: () => goToTab(context, Tabs.collection),
                        )
                      : SizedBox(
                          height: 56,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < 3; i++)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: revealed.contains(i)
                                        ? Court.ball
                                        : Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

    // --- Una carta y su etiqueta ---

  Widget _card(int i) {
    if (i >= widget.cards.length) return const SizedBox.shrink();
    final pack = widget.cards[i];
    final shown = revealed.contains(i);
    return SizedBox(
      width: 156,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Semantics(
            button: !shown,
            label: shown ? null : 'Revelar carta ${i + 1}',
            child: GestureDetector(
              onTap: shown ? null : () => setState(() => revealed.add(i)),
              child: FlipCard(
                flipped: shown,
                back: const CardBack(label: 'Toca para revelar'),
                front: PlayerCard(
                  card: pack.card,
                  number: widget.app.numberOf(pack.card),
                  total: widget.app.catalog.length,
                  copies: pack.copies,
                ),
              ),
            ),
          ),
          if (shown) Positioned(top: -12, child: _badge(pack)),
        ],
      ),
    );
  }

    /// Etiqueta "Nueva" o "Duplicada · ×N" sobre la carta revelada.
  Widget _badge(PackCard pack) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: pack.isNew ? Court.ball : Colors.white,
      borderRadius: BorderRadius.circular(99),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          pack.isNew ? Icons.star_rounded : Icons.copy_rounded,
          size: 13,
          color: pack.isNew ? Court.c900 : Court.c800,
        ),
        const SizedBox(width: 4),
        Text(
          pack.isNew ? 'Nueva' : 'Duplicada · ×${pack.copies}',
          style: body(
            12,
            weight: FontWeight.w700,
            color: pack.isNew ? Court.c900 : Court.c800,
          ),
        ),
      ],
    ),
  );
}

