import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/countries.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';
import 'widgets/team_slot.dart';

// --- El borrador ---

/// Elegir equipo: se arma un borrador y se guarda al final.
class TeamPage extends StatefulWidget {
  final AppController app;
  const TeamPage({super.key, required this.app});
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late final List<String> draft = List.of(widget.app.team);

  void toggle(String id) => setState(() {
    if (draft.contains(id)) {
      draft.remove(id);
    } else if (draft.length < 3) {
      draft.add(id);
    }
  });

  Future<void> save() async {
    try {
      await widget.app.saveTeam(draft);
      if (mounted) goToTab(context, Tabs.play);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError(e))));
      }
    }
  }
  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final owned = app.owned..sort((a, b) => a.ranking.compareTo(b.ranking));
    TennisCard byId(String id) => app.catalog.firstWhere((c) => c.id == id);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            TopBar('Elegir equipo', onBack: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: i < draft.length
                              ? TeamSlot(
                                  index: i,
                                  card: byId(draft[i]),
                                  number: app.numberOf(byId(draft[i])),
                                  onRemove: () => toggle(draft[i]),
                                )
                              : TeamSlot(index: i),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${draft.length} de 3 seleccionadas',
                          style: display(15, weight: FontWeight.w700),
                        ),
                      ),
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 24,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: i < draft.length ? Court.c800 : Court.line,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige tres tenistas diferentes. Las copias repetidas '
                    'cuentan como un solo tenista.',
                    style: body(12.5, color: Court.muted),
                  ),
                  const SizedBox(height: 16),
                  for (final card in owned) _row(card),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Court.paper,
          border: Border(top: BorderSide(color: Court.line)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CourtButton(
              'Guardar equipo',
              size: ButtonSize.lg,
              icon: Icons.check,
              full: true,
              onPressed: draft.length == 3 && !app.busy ? save : null,
            ),
            if (draft.length < 3) ...[
              const SizedBox(height: 6),
              Text(
                'Selecciona ${3 - draft.length} más para guardar',
                style: body(12, color: Court.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
  // --- Fila de un tenista ---

  /// Fila de un tenista obtenido: mini carta, datos y estado.
  Widget _row(TennisCard card) {
    final app = widget.app;
    final position = draft.indexOf(card.id);
    final selected = position >= 0;
    final blocked = !selected && draft.length == 3;
    final copies = app.copies[card.id] ?? 0;

    // Animaciones implícitas: al cambiar `selected` o `blocked`, Flutter
    // anima solo el cambio de opacidad, color y borde.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: blocked ? 0.45 : 1,
      child: GestureDetector(
        onTap: blocked ? null : () => toggle(card.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: selected ? Court.c50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Court.c700 : Court.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: PlayerCard(
                  card: card,
                  number: app.numberOf(card),
                  size: CardSize.xs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: display(15, weight: FontWeight.w700),
                    ),
                    Text(
                      countryName(card.country) +
                          (copies > 1 ? ' · ×$copies copias' : ''),
                      style: body(12, color: Court.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatStat(card, Challenge.ranking)}   '
                      '${card.titles} títulos   '
                      '${formatStat(card, Challenge.winRate)}',
                      style: body(
                        12,
                        weight: FontWeight.w600,
                        color: Court.c800,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Court.c800,
                      child: Icon(Icons.check, size: 17, color: Court.ball),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Espacio ${position + 1}',
                      style: body(
                        10.5,
                        weight: FontWeight.w700,
                        color: Court.c800,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Court.line, width: 2),
                  ),
                  child: Icon(
                    blocked ? Icons.lock_outline : Icons.add,
                    size: blocked ? 14 : 16,
                    color: Court.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
