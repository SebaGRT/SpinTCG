import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'navigation.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/card_hero.dart';
import 'widgets/common.dart';
import 'widgets/countries.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';

class DetailPage extends StatelessWidget {
  final AppController app;
  final TennisCard card;
  const DetailPage({super.key, required this.app, required this.card});

  Future<void> _toggle(BuildContext context) async {
    try {
      await app.toggleTeam(card.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final number = app.numberOf(card);
    final copies = app.copies[card.id] ?? 0;
    final slot = app.team.indexOf(card.id); // -1 si no está en el equipo
    final inTeam = slot >= 0;
    final teamFull = app.team.length == 3;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            TopBar(
              'Detalle de carta',
              onBack: () => Navigator.pop(context),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'N.º ${number.toString().padLeft(2, '0')}/${app.catalog.length}',
                  style: body(13, weight: FontWeight.w600, color: Court.muted),
                ),
              ),
            ),
            _bigCard(number, copies, inTeam),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _names(),
                  const SizedBox(height: 16),
                  _stats(),
                  const SizedBox(height: 12),
                  _copiesRow(copies),
                  const SizedBox(height: 12),
                  DemoTag(demo: app.isDemo),
                  const SizedBox(height: 20),
                  ..._actions(context, inTeam, slot, teamFull),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigCard(int number, int copies, bool inTeam) => Container(
    margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
    padding: const EdgeInsets.symmetric(vertical: 24),
    decoration: BoxDecoration(
      color: Court.c50,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Center(
      child: SizedBox(
        width: 230,
        child: CardHero(
          id: card.id,
          child: PlayerCard(
            card: card,
            number: number,
            total: app.catalog.length,
            copies: copies,
            size: CardSize.lg,
            inTeam: inTeam,
          ),
        ),
      ),
    ),
  );

  Widget _names() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        card.firstName,
        style: body(14, weight: FontWeight.w500, color: Court.muted),
      ),
      Text(card.lastName, style: display(30, height: 1)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _pill(
            '${card.country} · ${countryName(card.country)}',
            Colors.white,
            Court.ink,
            border: true,
          ),
          _pill('Circuito ATP', Court.c800, Court.ball),
        ],
      ),
    ],
  );

  Widget _pill(String text, Color bg, Color fg, {bool border = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
          border: border ? Border.all(color: Court.line) : null,
        ),
        child: Text(
          text,
          style: body(12.5, weight: FontWeight.w600, color: fg),
        ),
      );

  Widget _stats() => Row(
    children: [
      Expanded(
        child: StatBox(
          label: 'Ranking',
          value: formatStat(card, Challenge.ranking),
          hint: 'menor es mejor',
          emphasis: true,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: StatBox(
          label: 'Títulos',
          value: formatStat(card, Challenge.titles),
          hint: 'mayor es mejor',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: StatBox(
          label: '% victorias',
          value: formatStat(card, Challenge.winRate),
          hint: 'mayor es mejor',
        ),
      ),
    ],
  );

  Widget _copiesRow(int copies) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Court.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.copy_rounded, size: 18, color: Court.c700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Copias en tu colección',
            style: body(14, weight: FontWeight.w600),
          ),
        ),
        Text('×$copies', style: display(20)),
      ],
    ),
  );

  List<Widget> _actions(
    BuildContext context,
    bool inTeam,
    int slot,
    bool teamFull,
  ) {
    if (inTeam) {
      return [
        CourtButton(
          'Quitar del equipo',
          variant: ButtonVariant.secondary,
          size: ButtonSize.lg,
          icon: Icons.remove,
          full: true,
          onPressed: app.busy ? null : () => _toggle(context),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '✓ En tu equipo · Espacio ${slot + 1}',
            style: body(12.5, color: Court.muted),
          ),
        ),
      ];
    }
    if (!teamFull) {
      return [
        CourtButton(
          'Añadir al equipo',
          size: ButtonSize.lg,
          icon: Icons.add,
          full: true,
          onPressed: app.busy ? null : () => _toggle(context),
        ),
      ];
    }
    return [
      const CourtButton(
        'Añadir al equipo',
        size: ButtonSize.lg,
        icon: Icons.add,
        full: true,
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tu equipo está completo.',
            style: body(12.5, color: Court.muted),
          ),
          TextButton(
            onPressed: () => openPage(context, app, () => TeamPage(app: app)),
            child: Text(
              'Editar equipo',
              style: body(
                12.5,
                weight: FontWeight.w600,
                color: Court.c700,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    ];
  }
}
