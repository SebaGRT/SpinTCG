import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import '../domain/tennis_card.dart';
import 'detail_page.dart';
import 'errores.dart';
import 'navigation.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/countries.dart';
import 'widgets/player_card.dart';

class RankingPage extends StatefulWidget {
  final AppController app;
  const RankingPage({super.key, required this.app});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late Future<List<TennisCard>> ranking;

  @override
  void initState() {
    super.initState();
    ranking = fetch();
  }

  Future<List<TennisCard>> fetch() async {
    final cards = await widget.app.repository.load();
    return cards..sort((a, b) => a.ranking.compareTo(b.ranking));
  }

  void retry() => setState(() => ranking = fetch());

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          TopBar(
            'Ranking ATP',
            onBack: () => Navigator.pop(context),
            trailing: DemoTag(demo: widget.app.isDemo),
          ),
          Expanded(
            child: FutureBuilder<List<TennisCard>>(
              future: ranking,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return _error(snapshot.error!);
                final cards = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  itemCount: cards.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _row(cards[i]),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _error(Object error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40, color: Court.muted),
          const SizedBox(height: 12),
          Text(
            mensajeDeError(error),
            textAlign: TextAlign.center,
            style: body(14, color: Court.muted),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: retry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );

  Widget _row(TennisCard card) {
    final app = widget.app;
    final owned = (app.copies[card.id] ?? 0) > 0;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Court.line),
      ),
      child: ListTile(
        onTap: owned
            ? () =>
                  openPage(context, app, () => DetailPage(app: app, card: card))
            : null,
        leading: SizedBox(
          width: 40,
          child: Text(
            '#${card.ranking}',
            style: display(16, weight: FontWeight.w800, color: Court.c800),
          ),
        ),
        title: Text(card.name, style: body(15, weight: FontWeight.w600)),
        subtitle: Text(
          '${countryName(card.country)} ~ ${card.titles} títulos '
          '${formatStat(card, Challenge.winRate)}',
          style: body(12, color: Court.muted),
        ),
        trailing: owned
            ? const Icon(Icons.check_circle, color: Court.c700)
            : Text('Sin obtener', style: body(11, color: Court.muted)),
      ),
    );
  }
}
