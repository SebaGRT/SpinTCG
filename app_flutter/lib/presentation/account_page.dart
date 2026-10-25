import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/app_controller.dart';
import '../application/session_controller.dart';
import '../data/cloud.dart';
import '../domain/saved_team.dart';
import '../domain/tennis_card.dart';
import 'errores.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';
import 'widgets/team_name_dialog.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final TeamsRepository repo;
  late Future<List<SavedTeam>> teams;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    repo = context.read<TeamsRepository>();
    teams = repo.list();
  }

  void reload() => setState(() => teams = repo.list());

  void show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> change(Future<void> Function() action, String done) async {
    setState(() => busy = true);
    try {
      await action();
      if (mounted) show(done);
    } catch (e) {
      if (mounted) show(mensajeDeError(e));
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          teams = repo.list();
        });
      }
    }
  }

  Future<void> create(AppController app) async {
    final name = await askTeamName(context, title: 'Guardar equipo actual');
    if (name == null) return;
    await change(
      () => repo.create(name, app.team),
      'Equipo <<$name>> guardado',
    );
  }

  Future<void> rename(SavedTeam team) async {
    final name = await askTeamName(
      context,
      title: 'Cambiar nombre',
      initial: team.name,
    );
    if (name == null || name == team.name) return;
    await change(() => repo.rename(team.id, name), 'Nombre actualizado');
  }

  Future<void> delete(SavedTeam team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar equipo?'),
        content: Text('<<${team.name}>> se borrará de tu cuenta'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await change(() => repo.delete(team.id), 'Equipo borrado');
  }

  Future<void> use(AppController app, SavedTeam team) async {
    try {
      await app.saveTeam(team.cards);
      if (mounted) show('Ahora juegas con <<${team.name}>>');
    } catch (e) {
      if (mounted) show(mensajeDeError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await context.read<SessionController>().signOut();
    } catch (e) {
      if (mounted) show(mensajeDeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final session = context.watch<SessionController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopBar('Cuenta', onBack: () => Navigator.pop(context)),
            _account(session),
            _header(app),
            Expanded(
              child: FutureBuilder<List<SavedTeam>>(
                future: teams,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _message(
                      mensajeDeError(snapshot.error!),
                      retry: reload,
                    );
                  }
                  final list = snapshot.data!;
                  if (list.isEmpty) {
                    return _message(
                      'Aún no guardas equipos. Arma uno en Colección y guárdalo aquí',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [for (final team in list) _team(app, team)],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _account(SessionController session) => Container(
    margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
    decoration: BoxDecoration(
      color: Court.c50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.account_circle_outlined, color: Court.c700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            session.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body(14, weight: FontWeight.w600),
          ),
        ),
        CourtButton(
          'Salir',
          icon: Icons.logout,
          size: ButtonSize.sm,
          variant: ButtonVariant.ghost,
          onPressed: session.busy ? null : signOut,
        ),
      ],
    ),
  );

  Widget _header(AppController app) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
    child: Row(
      children: [
        Expanded(child: Text('Equipos guardados', style: display(20))),
        CourtButton(
          'Guardar actual',
          icon: Icons.add,
          size: ButtonSize.sm,
          onPressed: busy || app.team.length != 3 ? null : () => create(app),
        ),
      ],
    ),
  );

  Widget _message(String text, {VoidCallback? retry}) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: body(14, color: Court.muted),
          ),
          if (retry != null)
            TextButton(onPressed: retry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );

  Widget _team(AppController app, SavedTeam team) {
    final cards = [
      for (final id in team.cards) ...app.catalog.where((c) => c.id == id),
    ];
    final usable = team.cards.every((id) => (app.copies[id] ?? 0) > 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Court.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final card in cards) _mini(app, card),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  team.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: display(16, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CourtButton(
                'Usar',
                icon: Icons.sports_tennis,
                size: ButtonSize.sm,
                variant: ButtonVariant.secondary,
                onPressed: busy || !usable ? null : () => use(app, team),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Cambiar nombre',
                onPressed: busy ? null : () => rename(team),
                icon: const Icon(Icons.edit_outlined, color: Court.c700),
              ),
              IconButton(
                tooltip: 'Borrar',
                onPressed: busy ? null : () => delete(team),
                icon: const Icon(Icons.delete_outlined, color: Court.loss),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(AppController app, TennisCard card) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: SizedBox(
      width: 40,
      child: PlayerCard(
        card: card,
        number: app.numberOf(card),
        size: CardSize.xs,
      ),
    ),
  );
}
