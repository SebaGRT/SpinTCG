import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/app_controller.dart';
import '../application/session_controller.dart';
import '../data/cloud.dart';
import 'account_page.dart';
import 'errores.dart';
import 'navigation.dart';
import 'ranking_page.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';

// --- Estado y guardado ---

class ProfilePage extends StatefulWidget {
  final AppController app;
  const ProfilePage({super.key, required this.app});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final nickname = TextEditingController(text: widget.app.nickname);
  bool editing = false;
  String? error; // se muestra dentro del campo

  @override
  void dispose() {
    nickname.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      await widget.app.saveNickname(nickname.text);
      if (!mounted) return;
      setState(() {
        editing = false;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = mensajeDeError(e));
    }
  }

  // --- Reglas en una hoja ---

  void showRules() => showModalBottomSheet<void>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cómo se juega', style: display(20)),
          const SizedBox(height: 12),
          Text(
            'Juegas tres rondas contra la computadora. En cada ronda eliges '
            'una carta de tu equipo y se compara un atributo fijo. Cada carta '
            'se usa una sola vez; si los valores son iguales, la ronda queda '
            'empatada.',
            style: body(14, color: Court.muted),
          ),
          const SizedBox(height: 12),
          const RulesList(),
          const SizedBox(height: 4),
          Text(
            'Gana la partida quien consiga más rondas.',
            style: body(13, color: Court.muted),
          ),
        ],
      ),
    ),
  );

  // --- La pantalla ---

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            TopBar('Perfil', onBack: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            const Center(child: Avatar(size: 96)),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Avatar predeterminado',
                style: body(12, color: Court.muted),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: editing ? _editor(app) : _nickname(),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Apodo · máximo 16 caracteres',
                style: body(12, color: Court.muted),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // IntrinsicHeight + stretch: las tres cajas con la misma altura.
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatBox(
                        label: 'Cartas únicas',
                        value: '${app.uniqueCount}/${app.catalog.length}',
                        emphasis: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: 'Partidas',
                        value: '${app.played}',
                        hint: 'jugadas',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: 'Victorias',
                        value: '${app.wins}',
                        hint: app.played == 0
                            ? 'sin partidas'
                            : '${(app.wins * 100 / app.played).round()}% del total',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _link(Icons.info_outline, 'Cómo se juega', showRules),
            const SizedBox(height: 8),
            _link(
              Icons.leaderboard_outlined,
              'Ranking ATP',
              () => openPage(context, app, () => RankingPage(app: app)),
            ),
            // La cuenta solo existe con Supabase configurado.
            if (cloudEnabled) ...[const SizedBox(height: 8), _accountLink()],
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Tu progreso se guarda en este dispositivo.',
                textAlign: TextAlign.center,
                style: body(12, color: Court.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Ver y editar el apodo ---

  /// Apodo grande con el lápiz para editar.
  Widget _nickname() => Center(
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => editing = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(widget.app.nickname, style: display(26))),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Editar apodo',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Court.line),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: Court.c700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  /// Campo de texto + Guardar. El error aparece bajo el campo.
  Widget _editor(AppController app) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TextField(
          controller: nickname,
          autofocus: true,
          maxLength: 16,
          onSubmitted: (_) => save(),
          style: display(17, weight: FontWeight.w700),
          decoration: InputDecoration(
            counterText: '',
            errorText: error,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.c600, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.c600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.loss, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Court.loss, width: 2),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      CourtButton(
        'Guardar',
        icon: Icons.check,
        onPressed: app.busy ? null : save,
      ),
    ],
  );

  // --- Enlaces: reglas, ranking y cuenta ---

  /// Una fila blanca que abre algo. `subtitle` es opcional.
  Widget _link(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Court.line),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Court.c700),
        title: Text(title, style: body(15, weight: FontWeight.w600)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: body(12, color: Court.muted)),
        trailing: const Icon(Icons.chevron_right, color: Court.muted),
      ),
    ),
  );

  /// Cuenta de Supabase: muestra el correo de la sesión (Provider).
  Widget _accountLink() {
    final session = context.watch<SessionController>();
    return _link(
      Icons.cloud_outlined,
      'Cuenta y equipos guardados',
      () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const AccountPage())),
      subtitle: session.email,
    );
  }
}
