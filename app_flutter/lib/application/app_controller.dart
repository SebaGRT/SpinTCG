import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/catalog_repository.dart';
import '../data/local_store.dart';
import '../domain/game.dart';
import '../domain/tennis_card.dart';

String dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class AppController extends ChangeNotifier {
  final CatalogRepository repository;
  final LocalStore store;
  final Random random;
  final DateTime Function() now;

  AppController(
    this.repository,
    this.store, {
    Random? random,
    DateTime Function()? now,
  }) : random = random ?? Random(),
       now = now ?? DateTime.now;

  List<TennisCard> catalog = [];
  Map<String, int> copies = {};
  List<String> team = [];
  String nickname = 'Tenista';
  String? lastPackDay;
  int played = 0;
  int wins = 0;

  bool loading = true;
  bool busy = false;
  String? error;
  final Set<MatchSession> _recordedMatches = {};

  bool get isDemo => repository.isDemo;

  int get uniqueCount => copies.values.where((n) => n > 0).length;

  bool get canOpenPack =>
      lastPackDay == null || dayKey(now()).compareTo(lastPackDay!) > 0;

  List<TennisCard> get owned =>
      catalog.where((c) => (copies[c.id] ?? 0) > 0).toList();

  /// Las cartas del equipo, en orden.
  List<TennisCard> get selected =>
      team.map((id) => catalog.firstWhere((c) => c.id == id)).toList();

  /// Número de la carta en el álbum (N.º 01 de 24), según su orden.
  int numberOf(TennisCard card) =>
      catalog.indexWhere((c) => c.id == card.id) + 1;

  Map<String, dynamic> _snapshot() => {
    'version': 1,
    'catalog': catalog.map((c) => c.toJson()).toList(),
    'copies': Map<String, int>.of(copies),
    'team': List<String>.of(team),
    'nickname': nickname,
    'lastPackDay': lastPackDay,
    'played': played,
    'wins': wins,
  };

  void _restore(Map<String, dynamic> data) {
    if (data['version'] != 1) {
      throw const FormatException('Versión local no compatible');
    }
    catalog = (data['catalog'] as List)
        .map((c) => TennisCard.fromJson(Map<String, dynamic>.from(c)))
        .toList();
    copies = Map<String, int>.from(data['copies']);
    team = List<String>.from(data['team']);
    nickname = data['nickname'] as String;
    lastPackDay = data['lastPackDay'] as String?;
    played = data['played'] as int;
    wins = data['wins'] as int;
    if (!_isConsistent()) {
      throw const FormatException('El progreso guardado no es válido');
    }
  }

  bool _isConsistent() {
    final ids = catalog.map((c) => c.id).toSet();
    final catalogOk = catalog.length >= 6 && ids.length == catalog.length;
    final copiesOk = copies.entries.every(
      (e) => ids.contains(e.key) && e.value >= 0,
    );
    final teamOk =
        team.length <= 3 &&
        team.toSet().length == team.length &&
        team.every((id) => (copies[id] ?? 0) >= 1);
    final scoreOk = played >= 0 && wins >= 0 && wins <= played;
    return catalogOk && copiesOk && teamOk && scoreOk;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final saved = await store.read();
      if (saved != null) {
        _restore(saved);
      } else {
        catalog = await repository.load();
        final shuffled = List<TennisCard>.of(catalog)..shuffle(random);
        copies = {for (final c in shuffled.take(6)) c.id: 1};
        team = [];
        nickname = 'Tenista';
        lastPackDay = null;
        played = 0;
        wins = 0;
        await store.write(_snapshot());
      }
    } catch (e) {
      error = 'No se pudo cargar el proyecto: $e';
    }
    loading = false;
    notifyListeners();
  }

  Future<T> _change<T>(T Function() action) async {
    if (busy || loading || error != null) {
      throw StateError('Espera a que termine la operación');
    }
    busy = true;
    notifyListeners();
    final before = _snapshot();
    try {
      final value = action();
      await store.write(_snapshot());
      return value;
    } catch (_) {
      _restore(before);
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> toggleTeam(String id) => _change(() {
    if ((copies[id] ?? 0) < 1) throw ArgumentError('Carta no obtenida');
    if (team.contains(id)) {
      team.remove(id);
    } else {
      if (team.length == 3) throw StateError('El equipo ya tiene tres cartas');
      team.add(id);
    }
  });

  Future<void> saveTeam(List<String> ids) => _change(() {
    if (ids.length > 3 || ids.toSet().length != ids.length) {
      throw ArgumentError('Elige hasta tres tenistas diferentes');
    }
    if (ids.any((id) => (copies[id] ?? 0) < 1)) {
      throw ArgumentError('Carta no obtenida');
    }
    team = List.of(ids);
  });

  Future<List<TennisCard>> openPack() => _change(() {
    if (!canOpenPack) throw StateError('El sobre estará disponible mañana');
    final cards = List.generate(
      3,
      (_) => catalog[random.nextInt(catalog.length)],
    );
    for (final card in cards) {
      copies[card.id] = (copies[card.id] ?? 0) + 1;
    }
    lastPackDay = dayKey(now());
    return cards;
  });

  Future<void> saveNickname(String value) => _change(() {
    final clean = value.trim();
    if (clean.isEmpty || clean.length > 16) {
      throw ArgumentError('Usa un apodo de 1 a 16 caracteres');
    }
    nickname = clean;
  });

  MatchSession startMatch() {
    if (team.length != 3) throw StateError('Elige tres tenistas diferentes');
    final rival = catalog.where((c) => !team.contains(c.id)).toList()
      ..shuffle(random);
    return MatchSession(selected, rival.take(3).toList(), random: random);
  }

  Future<void> recordMatch(MatchSession match) async {
    if (_recordedMatches.contains(match)) return;
    await _change(() {
      if (!match.finished) throw StateError('La partida no ha terminado');
      played++;
      if (match.playerScore > match.opponentScore) wins++;
    });
    _recordedMatches.add(match);
  }

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }
}
