import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/game.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'match_page.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/court_lines.dart';
import 'widgets/player_card.dart';

// --- Guardar la partida ---

/// Resultado de la partida. Al abrirse guarda la partida en el progreso.
class ResultPage extends StatefulWidget {
  final AppController app;
  final MatchSession match;
  const ResultPage({super.key, required this.app, required this.match});
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool saving = false; // guardando ahora
  bool saved = false; // ya quedó guardada
  String? saveError; // mensaje si falló el guardado

  MatchSession get m => widget.match;

  /// 1 = ganaste, -1 = perdiste, 0 = empate.
  int get outcome => (m.playerScore - m.opponentScore).sign;

  @override
  void initState() {
    super.initState();
    // Se guarda después del primer frame: guardar avisa al controlador, y
    // no se puede redibujar mientras esta pantalla se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) => record());
  }

  /// Suma la partida al progreso. Se puede reintentar sin contarla dos veces.
  Future<void> record() async {
    setState(() {
      saving = true;
      saveError = null;
    });
    try {
      await widget.app.recordMatch(widget.match);
      saved = true;
    } catch (e) {
      saveError = 'No se guardó el resultado: ${mensajeDeError(e)}';
    }
    if (mounted) setState(() => saving = false);
  }

    /// Nueva partida con el mismo equipo; reemplaza esta pantalla.
  void playAgain() {
    final match = widget.app.startMatch();
    openPage(
      context,
      widget.app,
      () => MatchPage(app: widget.app, match: match),
      replace: true,
    );
  }

    // --- La pantalla ---

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving, // no se puede salir mientras se guarda
    child: Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [_header(), _summary(context)],
      ),
    ),
  );

    // --- Encabezado según el resultado ---

  Widget _header() {
    final win = outcome == 1;
    final String title;
    final String subtitle;
    final IconData icon;
    final Color background;
    final Color iconColor;
    switch (outcome) {
      case 1:
        title = '¡Victoria!';
        subtitle = 'Ganaste la partida contra la computadora.';
        icon = Icons.emoji_events_outlined;
        background = Court.c800;
        iconColor = Court.c900;
      case -1:
        title = 'Derrota';
        subtitle = 'La computadora ganó esta vez. ¡Prueba otra vez!';
        icon = Icons.close;
        background = Court.segment;
        iconColor = Court.loss;
      default:
        title = 'Empate';
        subtitle = 'Nadie se llevó la partida. Igualdad total.';
        icon = Icons.drag_handle;
        background = Court.c50;
        iconColor = Court.c800;
    }
    final onHeader = win ? Colors.white : Court.ink; // texto principal
    final soft = win ? Colors.white.withValues(alpha: 0.75) : Court.muted;

    return Container(
      color: background,
      child: Stack(
        children: [
          if (win) const CourtLines(opacity: 0.1),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: win ? Court.ball : Colors.white,
                      shape: BoxShape.circle,
                      border: win ? null : Border.all(color: Court.line),
                    ),
                    child: Icon(icon, size: 38, color: iconColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: display(
                      36,
                      weight: FontWeight.w900,
                      color: onHeader,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: body(14, color: soft),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _score(
                        'Tú',
                        m.playerScore,
                        win ? Court.ball : Court.muted,
                        onHeader,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '–',
                          style: display(
                            28,
                            color: onHeader.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      _score('CPU', m.opponentScore, soft, onHeader),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _score(String label, int value, Color labelColor, Color color) =>
      Column(
        children: [
          Text(
            label,
            style: body(12, weight: FontWeight.w600, color: labelColor),
          ),
          Text('$value', style: display(44, color: color, height: 1)),
        ],
      );

        // --- Resumen, guardado y botones ---

  Widget _summary(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen de rondas', style: display(16, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (var i = 0; i < m.results.length; i++) _roundRow(i, m.results[i]),
        DemoTag(demo: widget.app.isDemo),
        const SizedBox(height: 12),
        if (saving) const LinearProgressIndicator(),
        if (saved)
          Text('Resultado guardado', style: body(12, color: Court.muted)),
        if (saveError != null) ...[
          Text(saveError!, style: body(13, color: Court.loss)),
          const SizedBox(height: 8),
          CourtButton(
            'Reintentar guardado',
            variant: ButtonVariant.secondary,
            onPressed: saving ? null : record,
          ),
        ],
        const SizedBox(height: 20),
        CourtButton(
          'Volver a jugar',
          variant: ButtonVariant.accent,
          size: ButtonSize.lg,
          icon: Icons.refresh,
          full: true,
          // Solo cuando ya se guardó: si no, esta partida podría perderse.
          onPressed: saving || !saved ? null : playAgain,
        ),
        const SizedBox(height: 8),
        CourtButton(
          'Ir al inicio',
          variant: ButtonVariant.secondary,
          size: ButtonSize.lg,
          icon: Icons.home_outlined,
          full: true,
          onPressed: saving ? null : () => goToTab(context, Tabs.home),
        ),
        const SizedBox(height: 32),
      ],
    ),
  );

    // --- Una fila del resumen ---

  /// Una fila del resumen: ronda, atributo, valores y quién ganó.
  Widget _roundRow(int i, RoundResult r) {
    final (String label, Color bg, Color fg) = switch (r.outcome) {
      1 => ('Ganada', Court.ball, Court.c900),
      0 => ('Empate', Court.c50, Court.c800),
      _ => ('Perdida', Court.locked, Court.muted),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Court.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ronda ${i + 1} · ${r.challenge.label}',
                  style: body(12, weight: FontWeight.w600, color: Court.muted),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  label,
                  style: body(11.5, weight: FontWeight.w700, color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  r.player.lastName,
                  overflow: TextOverflow.ellipsis,
                  style: body(
                    14,
                    weight: r.outcome == 1 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(formatStat(r.player, r.challenge), style: display(14)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('vs', style: body(12, color: Court.muted)),
              ),
              Text(formatStat(r.opponent, r.challenge), style: display(14)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.opponent.lastName,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: body(
                    14,
                    weight: r.outcome == -1 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}