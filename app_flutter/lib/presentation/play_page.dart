import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'match_page.dart';
import 'navigation.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/team_slot.dart';

class PlayPage extends StatelessWidget {
  final AppController app;
  const PlayPage({super.key, required this.app});

  void _openTeam(BuildContext context) =>
      openPage(context, app, () => TeamPage(app: app));

  void _start(BuildContext context) {
    final match = app.startMatch();
    openPage(context, app, () => MatchPage(app: app, match: match));
  }

  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final chosen = app.team.length;
    final missing = 3 - chosen;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const ScreenTitle(
          'Jugar',
          subtitle: 'Partida rápida contra la computadora',
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Court.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cómo se juega',
                style: display(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Tres rondas con un atributo fijo cada una. Elige una carta '
                'por ronda; cada carta se usa una sola vez. Si los valores '
                'son iguales, la ronda queda empatada.',
                style: body(13, color: Court.muted),
              ),
              const SizedBox(height: 12),
              const RulesList(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Tu equipo ',
                        style: display(17, weight: FontWeight.w700),
                        children: [
                          TextSpan(
                            text: '· $chosen de 3',
                            style: body(
                              13,
                              weight: FontWeight.w500,
                              color: Court.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CourtButton(
                    'Cambiar equipo',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    icon: Icons.swap_horiz,
                    onPressed: () => _openTeam(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: i < chosen
                          ? TeamSlot(
                              index: i,
                              card: app.selected[i],
                              number: app.numberOf(app.selected[i]),
                            )
                          : TeamSlot(index: i, onTap: () => _openTeam(context)),
                    ),
                  ],
                ],
              ),
              if (missing > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Court.ball.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Court.ballDark.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Court.c900,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: body(13, color: Court.c900),
                            children: [
                              TextSpan(
                                text: missing == 1
                                    ? 'Te falta 1 tenista. '
                                    : 'Te faltan $missing tenistas. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    'Pulsa «Cambiar equipo» o ve a '
                                    'Colección › Elegir equipo y selecciona '
                                    'tres tenistas diferentes.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CourtButton(
            'Iniciar partida',
            variant: ButtonVariant.accent,
            size: ButtonSize.lg,
            icon: Icons.sports_baseball_outlined,
            full: true,
            onPressed: missing == 0 && !app.busy ? () => _start(context) : null,
          ),
        ),
      ],
    );
  }
}
