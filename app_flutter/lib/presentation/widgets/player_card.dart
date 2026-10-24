import 'package:flutter/material.dart';
import '../../domain/tennis_card.dart';
import '../theme.dart';
import 'countries.dart';
import 'court_lines.dart';
import 'player_figure.dart';

String formatStat(TennisCard card, Challenge challenge) => switch (challenge) {
  Challenge.ranking => '#${card.ranking}',
  Challenge.titles => '${card.titles}',
  Challenge.winRate =>
    card.winRate == card.winRate.roundToDouble()
        ? '${card.winRate.toInt()}%'
        : '${card.winRate.toStringAsFixed(1)}%',
};

enum CardSize { xs, sm, lg }

class _Style {
  final double pad, radius, inner, rank, last, first, meta;
  final EdgeInsets rankPad, bodyPad;

  const _Style(
    this.pad,
    this.radius,
    this.inner,
    this.rank,
    this.last,
    this.first,
    this.meta,
    this.rankPad,
    this.bodyPad,
  );

  static _Style of(CardSize size) => switch (size) {
    CardSize.xs => const _Style(
      4,
      14,
      10,
      11,
      12.5,
      9.5,
      10,
      EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      EdgeInsets.fromLTRB(4, 6, 4, 2),
    ),

    CardSize.sm => const _Style(
      6,
      18,
      13,
      13,
      16,
      11,
      11.5,
      EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      EdgeInsets.fromLTRB(6, 8, 6, 4),
    ),

    CardSize.lg => const _Style(
      8,
      24,
      18,
      17,
      24,
      13,
      13,
      EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      EdgeInsets.fromLTRB(10, 12, 10, 8),
    ),
  };
}

class PlayerCard extends StatelessWidget {
  final TennisCard card;
  final int number;
  final int total;
  final int copies;
  final CardSize size;
  final bool locked;
  final bool inTeam;
  final VoidCallback? onTap;

  const PlayerCard({
    super.key,
    required this.card,
    required this.number,
    this.total = 24,
    this.copies = 0,
    this.size = CardSize.sm,
    this.locked = false,
    this.inTeam = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = _Style.of(size);
    final content = AspectRatio(
      aspectRatio: 5 / 7,
      child: Container(
        padding: EdgeInsets.all(s.pad),
        decoration: BoxDecoration(
          color: locked ? Court.locked : Colors.white,
          borderRadius: BorderRadius.circular(s.radius),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: locked
              ? null
              : [
                  BoxShadow(
                    color: Court.c900.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Court.c900.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: -8,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _portrait(s)),
            Padding(
              padding: s.bodyPad,
              child: locked ? _lockedBody(s) : _body(s),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: card.name,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }

  Widget _portrait(_Style s) => ClipRRect(
    borderRadius: BorderRadius.circular(s.inner),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: locked ? Court.lockedInner : null,
        gradient: locked
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Court.c700, Court.c900],
              ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!locked) const CourtLines(),
          PlayerFigure(seed: number - 1, silhouette: locked),
          Positioned(
            left: 6,
            top: 6,
            child: _chip(
              locked ? '#—' : '#${card.ranking}',
              background: locked
                  ? Colors.white.withValues(alpha: 0.7)
                  : Court.ball,
              style: display(
                s.rank,
                color: locked ? Court.muted : Court.c900,
                weight: locked ? FontWeight.w700 : FontWeight.w800,
              ),
              padding: s.rankPad,
            ),
          ),
          if (!locked)
            Positioned(
              right: 6,
              top: 6,
              child: _chip(
                card.country,
                background: Colors.black.withValues(alpha: 0.25),
                style: display(
                  size == CardSize.xs ? 9 : 11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ).copyWith(letterSpacing: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          if (inTeam && !locked)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 11, color: Court.c800),
                    const SizedBox(width: 2),
                    Text(
                      'En equipo',
                      style: body(
                        size == CardSize.xs ? 9 : 10.5,
                        weight: FontWeight.w700,
                        color: Court.c800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _chip(
    String text, {
    required Color background,
    required TextStyle style,
    required EdgeInsets padding,
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: style),
  );

  Widget _body(_Style s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (size != CardSize.xs)
        Text(
          card.firstName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: body(s.first, weight: FontWeight.w500, color: Court.muted),
        ),
      Text(
        card.lastName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: display(s.last, color: Court.ink),
      ),
      const SizedBox(height: 2),
      Row(
        children: [
          Expanded(
            child: Text(
              size == CardSize.xs ? card.country : countryName(card.country),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body(s.meta, color: Court.muted),
            ),
          ),
          if (copies > 0 && size != CardSize.xs) _copiesChip(s),
        ],
      ),
    ],
  );

  Widget _copiesChip(_Style s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      color: copies > 1 ? Court.ball.withValues(alpha: 0.6) : Court.c50,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.copy_rounded,
          size: 11,
          color: copies > 1 ? Court.c900 : Court.c700,
        ),
        const SizedBox(width: 2),
        Text(
          '×$copies',
          style: display(
            s.meta,
            weight: FontWeight.w700,
            color: copies > 1 ? Court.c900 : Court.c700,
          ),
        ),
      ],
    ),
  );

  Widget _lockedBody(_Style s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: size == CardSize.lg ? 18 : 13,
            color: Court.muted,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Sin obtener',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: display(
                s.last,
                weight: FontWeight.w700,
                color: Court.muted,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        'N.º ${number.toString().padLeft(2, '0')} de $total',
        style: body(s.meta, color: Court.disabledText),
      ),
    ],
  );
}
