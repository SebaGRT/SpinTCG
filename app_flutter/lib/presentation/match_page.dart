import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/game.dart';
import '../domain/tennis_card.dart';
import 'theme.dart';
import 'widgets/card_back.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/flip_card.dart';
import 'widgets/player_card.dart';
import 'navigation.dart';
import 'result_page.dart';

class MatchPage extends StatefulWidget {
  final AppController app;
  final MatchSession match;
  const MatchPage({super.key, required this.app, required this.match});
  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final List<TennisCard> hand = List.of(widget.match.remaining);
  String? selected;
  RoundResult? current;

  MatchSession get m => widget.match;
  int get round => current == null ? m.results.length : m.results.length - 1;
  Challenge get challenge => Challenge.values[round];

  void confirm() => setState(() => current = m.play(selected!));

  void next() {
    if (m.finished) {
      openPage(
        context,
        widget.app,
        () => ResultPage(app: widget.app, match: m),
        replace: true,
      );
    } else {
      setState(() {
        selected = null;
        current = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _topRow(),
          _scoreboard(),
          const SizedBox(height: 12),
          _challengeBanner(),
          const SizedBox(height: 16),
          _duel(),
          const SizedBox(height: 16),
          _hand(),
          const SizedBox(height: 20),
          current != null
              ? CourtButton(
                  m.finished ? 'Ver resultado' : 'Siguiente ronda',
                  variant: ButtonVariant.accent,
                  size: ButtonSize.lg,
                  iconRight: Icons.chevron_right,
                  full: true,
                  onPressed: next,
                )
              : CourtButton(
                  selected == null ? 'Elige una carta' : 'Confirmar elección',
                  size: ButtonSize.lg,
                  full: true,
                  onPressed: selected == null ? null : confirm,
                ),
        ],
      ),
    ),
  );

  // --- Ronda y marcador ---

  /// Cerrar (abandonar no suma partidas), ronda actual y tres puntos.
  Widget _topRow() => SizedBox(
    height: 56,
    child: Row(
      children: [
        RoundIconButton(
          icon: Icons.close,
          tooltip: 'Salir de la partida',
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'Ronda ${round + 1} de 3',
            textAlign: TextAlign.center,
            style: display(15, weight: FontWeight.w700),
          ),
        ),
        SizedBox(
          width: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                _dot(i),
              ],
            ],
          ),
        ),
      ],
    ),
  );

  Widget _dot(int i) {
    final outcome = i < m.results.length ? m.results[i].outcome : null;
    final (Color color, Color? border) = switch (outcome) {
      null => (i == round ? Court.c800 : Court.line, null),
      1 => (Court.ball, Court.c800),
      0 => (Colors.white, Court.muted),
      _ => (Court.muted, null),
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border),
      ),
    );
  }

  Widget _scoreboard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Court.line),
    ),
    child: Row(
      children: [
        const Avatar(size: 30),
        const SizedBox(width: 8),
        Text('Tú', style: body(14, weight: FontWeight.w600)),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '${m.playerScore} ',
              children: [
                TextSpan(
                  text: '–',
                  style: TextStyle(color: Court.muted.withValues(alpha: 0.5)),
                ),
                TextSpan(text: ' ${m.opponentScore}'),
              ],
            ),
            textAlign: TextAlign.center,
            style: display(28, height: 1),
          ),
        ),
        Text('CPU', style: body(14, weight: FontWeight.w600)),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 15,
          backgroundColor: Court.ink,
          child: Icon(Icons.memory, size: 17, color: Colors.white),
        ),
      ],
    ),
  );

  // --- Atributo de la ronda ---

  Widget _challengeBanner() => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Court.c800,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        const CourtLines(opacity: 0.1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Wrap: si la regla no cabe al lado del atributo, baja a otra línea.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATRIBUTO DE LA RONDA',
                    style: body(
                      11.5,
                      weight: FontWeight.w600,
                      color: Court.ball,
                    ).copyWith(letterSpacing: 0.9),
                  ),
                  Text(
                    challenge.label,
                    style: display(26, color: Colors.white, height: 1.2),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      challenge.lowerWins
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        challenge.rule,
                        style: body(
                          12,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // --- El duelo ---

  /// Tu carta contra la carta oculta de la computadora.
  Widget _duel() {
    TennisCard? mine;
    if (selected != null) mine = hand.firstWhere((c) => c.id == selected);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu carta',
                style: body(12, weight: FontWeight.w600, color: Court.muted),
              ),
              const SizedBox(height: 6),
              Center(
                child: SizedBox(
                  width: 128,
                  child: mine == null
                      ? AspectRatio(
                          aspectRatio: 5 / 7,
                          child: DashedBorder(
                            fill: Court.c50.withValues(alpha: 0.6),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_downward,
                                    size: 18,
                                    color: Court.c700,
                                  ),
                                  Text(
                                    'Elige una carta abajo',
                                    textAlign: TextAlign.center,
                                    style: body(
                                      12,
                                      weight: FontWeight.w600,
                                      color: Court.c700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : _mini(mine),
                ),
              ),
              if (current != null) _valueBox(current!.player, current!.outcome),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Computadora',
                style: body(12, weight: FontWeight.w600, color: Court.muted),
              ),
              const SizedBox(height: 6),
              Center(
                child: SizedBox(
                  width: 128,
                  child: FlipCard(
                    key: ValueKey(round), // ronda nueva = carta boca abajo
                    flipped: current != null,
                    back: const CardBack(label: 'Oculta'),
                    front: current == null
                        ? const SizedBox.shrink()
                        : _mini(current!.opponent),
                  ),
                ),
              ),
              if (current != null)
                _valueBox(current!.opponent, -current!.outcome),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mini(TennisCard card) => PlayerCard(
    card: card,
    number: widget.app.numberOf(card),
    size: CardSize.xs,
  );

  // --- Valor comparado ---

  /// Valor comparado con su resultado: Gana / Empate / Pierde.
  Widget _valueBox(TennisCard card, int outcome) {
    final (
      Color bg,
      Color fg,
      Color border,
      IconData icon,
      String label,
    ) = switch (outcome) {
      1 => (Court.ball, Court.c900, Court.c800, Icons.check, 'Gana'),
      0 => (Colors.white, Court.ink, Court.muted, Icons.drag_handle, 'Empate'),
      _ => (Court.locked, Court.muted, Court.line, Icons.close, 'Pierde'),
    };
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: outcome == -1 ? 1 : 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatStat(card, challenge),
              style: display(24, color: fg, height: 1),
            ),
          ),
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 2),
          Text(
            label,
            style: body(12, weight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }

  // --- Tus cartas ---

  /// Tus tres cartas con el valor del atributo de esta ronda.
  Widget _hand() {
    final used = m.results.map((r) => r.player.id).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tus cartas · ${challenge.label}',
                style: body(12, weight: FontWeight.w600, color: Court.muted),
              ),
            ),
            DemoTag(demo: widget.app.isDemo),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < hand.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _handCard(hand[i], used)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _handCard(TennisCard card, Set<String> used) {
    final isSelected = selected == card.id;
    final isUsed = used.contains(card.id) && current?.player.id != card.id;
    final locked = isUsed || current != null;
    final (Color bg, Color fg) = isUsed
        ? (Court.locked, Court.muted)
        : isSelected
        ? (Court.c800, Colors.white)
        : (Colors.white, Court.ink);
    return Opacity(
      opacity: current != null && !isSelected ? 0.6 : 1,
      child: GestureDetector(
        key: ValueKey('mano-${card.id}'), // los tests tocan la carta por su id
        onTap: locked ? null : () => setState(() => selected = card.id),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Court.c900 : Court.line,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.lastName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: display(13, weight: FontWeight.w700, color: fg),
              ),
              Text(
                formatStat(card, challenge),
                style: display(20, color: fg, height: 1.2).copyWith(
                  decoration: isUsed ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                isUsed
                    ? 'Usada'
                    : isSelected
                    ? '✓ Elegida'
                    : 'Disponible',
                style: body(
                  10.5,
                  weight: FontWeight.w600,
                  color: isSelected ? Court.ball : fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
