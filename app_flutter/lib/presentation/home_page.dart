import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'app_shell.dart';
import 'navigation.dart';
import 'profile_page.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/pack_art.dart';
import 'widgets/team_slot.dart';

class HomePage extends StatelessWidget {
  final AppController app;
  const HomePage({super.key, required this.app});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    children: [
      _header(context),
      const SizedBox(height: 20),
      Text('Hola, ${app.nickname}', style: body(14, color: Court.muted)),
      const SizedBox(height: 2),
      Text(
        app.canOpenPack
            ? 'Tu sobre diario te espera'
            : '¿Listo para la próxima partida?',
        style: display(28, height: 1.05),
      ),
      const SizedBox(height: 20),
      _collectionCard(context),
      const SizedBox(height: 20),
      CourtButton(
        'Jugar partida',
        variant: ButtonVariant.accent,
        size: ButtonSize.lg,
        icon: Icons.sports_baseball_outlined,
        full: true,
        onPressed: () => goToTab(context, Tabs.play),
      ),
      const SizedBox(height: 20),
      _packCard(context),
      const SizedBox(height: 20),
      _teamSection(context),
    ],
  );

  Widget _header(BuildContext context) => Row(
    children: [
      const BrandLogo(),
      const SizedBox(width: 8),
      Expanded(child: Text(kBrand, style: display(19))),
      Tooltip(
        message: 'Perfil',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => openPage(context, app, () => ProfilePage(app: app)),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Avatar(size: 42),
          ),
        ),
      ),
    ],
  );

  Widget _collectionCard(BuildContext context) {
    final total = app.catalog.length;
    return GestureDetector(
      onTap: () => goToTab(context, Tabs.collection),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Court.c800,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            const CourtLines(opacity: 0.1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu colección',
                              style: body(
                                13,
                                weight: FontWeight.w600,
                                color: Court.ball,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                text: '${app.uniqueCount}',
                                style: display(
                                  40,
                                  color: Colors.white,
                                  height: 1,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' / $total',
                                    style: display(
                                      22,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'cartas únicas obtenidas',
                              style: body(
                                13,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Ver',
                        style: body(
                          13,
                          weight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : app.uniqueCount / total,
                      minHeight: 8,
                      color: Court.ball,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _packCard(BuildContext context) {
    final opened = !app.canOpenPack;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Court.line),
      ),
      child: Row(
        children: [
          PackArt(width: 58, opened: opened),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu sobre diario',
                  style: display(16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  opened
                      ? 'Abierto hoy · Disponible mañana'
                      : '3 cartas aleatorias, gratis cada día',
                  style: body(13, color: Court.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (opened)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Court.c50,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 14, color: Court.c700),
                  const SizedBox(width: 4),
                  Text(
                    'Abierto',
                    style: body(12, weight: FontWeight.w600, color: Court.c700),
                  ),
                ],
              ),
            )
          else
            CourtButton(
              'Abrir sobre',
              size: ButtonSize.sm,
              onPressed: () => goToTab(context, Tabs.packs),
            ),
        ],
      ),
    );
  }

  Widget _teamSection(BuildContext context) {
    final full = app.team.length == 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tu equipo',
                style: display(17, weight: FontWeight.w700),
              ),
            ),
            if (full)
              TextButton(
                onPressed: () =>
                    openPage(context, app, () => TeamPage(app: app)),
                child: Text(
                  'Editar',
                  style: body(13, weight: FontWeight.w600, color: Court.c700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (full)
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: TeamSlot(
                    index: i,
                    card: app.selected[i],
                    number: app.numberOf(app.selected[i]),
                  ),
                ),
              ],
            ],
          )
        else
          DashedBorder(
            radius: 24,
            fill: Court.c50.withValues(alpha: 0.6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Court.c200),
                        ),
                        child: const Icon(
                          Icons.style_outlined,
                          size: 20,
                          color: Court.c700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elige tu equipo',
                              style: display(16, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Selecciona tres tenistas diferentes para poder '
                              'jugar. ${app.team.length} de 3 elegidos.',
                              style: body(13, color: Court.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CourtButton(
                    'Ir a Colección',
                    variant: ButtonVariant.secondary,
                    iconRight: Icons.chevron_right,
                    full: true,
                    onPressed: () => goToTab(context, Tabs.collection),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
