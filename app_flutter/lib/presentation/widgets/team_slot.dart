import 'package:flutter/material.dart';
import '../../domain/tennis_card.dart';
import '../theme.dart';
import 'common.dart';
import 'player_card.dart';

/// Uno de los tres espacios del equipo. Vacío muestra "Espacio N" con borde
/// discontinuo; lleno muestra la carta pequeña con su número.
/// `onRemove` agrega la X para quitar la carta (pantalla Elegir equipo).
class TeamSlot extends StatelessWidget {
  final int index;
  final TennisCard? card;
  final int number;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  const TeamSlot({
    super.key,
    required this.index,
    this.card,
    this.number = 0,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 5 / 7,
          child: DashedBorder(
            fill: Court.c50.withValues(alpha: 0.6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Court.c200),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Court.c700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Espacio ${index + 1}',
                  style: body(11, weight: FontWeight.w600, color: Court.c700),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onRemove ?? onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PlayerCard(card: card!, number: number, size: CardSize.xs),
          Positioned(
            left: -4,
            top: -4,
            child: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Court.c800,
                shape: BoxShape.circle,
                border: Border.all(color: Court.paper, width: 2),
              ),
              child: Text(
                '${index + 1}',
                style: display(
                  11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              right: -4,
              top: -4,
              child: Semantics(
                button: true,
                label: 'Quitar a ${card!.lastName}',
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Court.line),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 13, color: Court.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
