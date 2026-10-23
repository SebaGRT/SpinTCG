import 'package:flutter/material.dart';
import '../theme.dart';
import 'court_lines.dart';

/// Reverso de una carta (sobre sin revelar y carta oculta del rival).
class CardBack extends StatelessWidget {
  final String? label;
  const CardBack({super.key, this.label});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 5 / 7,
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Court.c700, Court.c900],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: -12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 4,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CourtLines(opacity: 0.2),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Court.ball,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_baseball_outlined,
                  size: 26,
                  color: Court.c900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kBrand.toUpperCase(),
                style: display(
                  13,
                  color: Colors.white,
                ).copyWith(letterSpacing: 1.5),
              ),
              if (label != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    label!,
                    style: body(
                      11,
                      weight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
