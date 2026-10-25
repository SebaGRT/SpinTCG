import 'package:flutter/material.dart';
import '../application/app_controller.dart';
import 'detail_page.dart';
import 'navigation.dart';
import 'team_page.dart';
import 'theme.dart';
import 'widgets/card_hero.dart';
import 'widgets/common.dart';
import 'widgets/court_button.dart';
import 'widgets/player_card.dart';

String normalize(String text) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñçš';
  const to = 'aaaaeeeeiiiioooouuuuncs';
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final char in lower.split('')) {
    final i = from.indexOf(char);
    out.write(i == -1 ? char : to[i]);
  }
  return out.toString();
}

class CollectionPage extends StatefulWidget {
  final AppController app;
  const CollectionPage({super.key, required this.app});
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final search = TextEditingController();
  bool duplicatesOnly = false;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final query = normalize(search.text.trim());
    final duplicateCount = app.copies.values.where((n) => n > 1).length;
    final cards = app.catalog.where((card) {
      final copies = app.copies[card.id] ?? 0;
      if (duplicatesOnly && copies < 2) return false;
      // Al buscar, solo aparecen cartas obtenidas (las demás son secretas).
      if (query.isNotEmpty) {
        return copies > 0 && normalize(card.name).contains(query);
      }
      return true;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenTitle(
            'Colección',
            subtitle:
                '${app.uniqueCount} de ${app.catalog.length} cartas únicas',
            trailing: CourtButton(
              'Elegir equipo',
              size: ButtonSize.sm,
              icon: Icons.swap_horiz,
              onPressed: () => openPage(context, app, () => TeamPage(app: app)),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              children: [
                _searchField(),
                const SizedBox(height: 12),
                _segmented(app.catalog.length, duplicateCount),
              ],
            ),
          ),
        ),
        if (cards.isEmpty)
          SliverToBoxAdapter(child: _empty(query.isNotEmpty))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 5 / 7,
              children: [
                for (final card in cards)
                  CardHero(
                    id: card.id,
                    child: PlayerCard(
                      card: card,
                      number: app.numberOf(card),
                      total: app.catalog.length,
                      copies: app.copies[card.id] ?? 0,
                      locked: (app.copies[card.id] ?? 0) == 0,
                      inTeam: app.team.contains(card.id),
                      onTap: (app.copies[card.id] ?? 0) == 0
                          ? null
                          : () => openPage(
                              context,
                              app,
                              () => DetailPage(app: app, card: card),
                            ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _searchField() => TextField(
    controller: search,
    onChanged: (_) => setState(() {}),
    style: body(15),
    decoration: InputDecoration(
      hintText: 'Buscar por nombre',
      hintStyle: body(15, color: Court.disabledText),
      prefixIcon: const Icon(Icons.search, color: Court.muted),
      suffixIcon: search.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Borrar búsqueda',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(search.clear),
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Court.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Court.c600, width: 2),
      ),
    ),
  );

  Widget _segmented(int total, int duplicates) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Court.segment,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        _segment('Todas', total, !duplicatesOnly, false),
        _segment('Duplicadas', duplicates, duplicatesOnly, true),
      ],
    ),
  );

  Widget _segment(String label, int count, bool active, bool value) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => duplicatesOnly = value),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? const [BoxShadow(color: Colors.black12, blurRadius: 2)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (active) ...[
              const Icon(Icons.check, size: 15, color: Court.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: body(
                14,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Court.ink : Court.muted,
              ),
            ),
            const SizedBox(width: 6),
            Text('$count', style: body(14, color: Court.muted)),
          ],
        ),
      ),
    ),
  );

  Widget _empty(bool searching) {
    final noDuplicates = duplicatesOnly && !searching;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: DashedBorder(
        radius: 24,
        color: Court.line,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Icon(
                noDuplicates ? Icons.copy_rounded : Icons.search,
                size: 26,
                color: Court.muted,
              ),
              const SizedBox(height: 12),
              Text(
                noDuplicates
                    ? 'Aún no tienes cartas duplicadas'
                    : 'Sin resultados',
                style: display(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                noDuplicates
                    ? 'Abre tu sobre diario para conseguir copias.'
                    : 'No tienes cartas que coincidan con «${search.text}».',
                textAlign: TextAlign.center,
                style: body(13, color: Court.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
