import 'dart:math';
import 'tennis_card.dart';

class RoundResult {
  final TennisCard player;
  final TennisCard opponent;
  final Challenge challenge;

  final int outcome;
  RoundResult(this.player, this.opponent, this.challenge, this.outcome);
}

int compareCards(TennisCard a, TennisCard b, Challenge challenge) {
  final comparison = a.value(challenge).compareTo(b.value(challenge));
  return challenge.lowerWins ? -comparison : comparison;
}

class MatchSession {
  final List<TennisCard> remaining;
  final List<TennisCard> opponents;
  final Random random;
  final List<RoundResult> results = [];

  MatchSession(List<TennisCard> team, List<TennisCard> rival, {Random? random})
    : remaining = List.of(team),
      opponents = List.of(rival),
      random = random ?? Random() {
    if (!_threeDifferent(team) || !_threeDifferent(rival)) {
      throw ArgumentError('Cada equipo necesita tres tenistas diferentes');
    }
  }

  static bool _threeDifferent(List<TennisCard> cards) =>
      cards.length == 3 && cards.map((c) => c.id).toSet().length == 3;

  bool get finished => results.length == 3;

  Challenge get challenge => Challenge.values[results.length];

  int get playerScore => results.where((r) => r.outcome == 1).length;
  int get opponentScore => results.where((r) => r.outcome == -1).length;

  RoundResult play(String id) {
    if (finished) throw StateError('La partida terminó');
    final index = remaining.indexWhere((c) => c.id == id);
    if (index == -1) throw ArgumentError('Carta no disponible');

    final roundChallenge = challenge;
    final card = remaining.removeAt(index);
    final opponent = opponents.removeAt(random.nextInt(opponents.length));
    final outcome = compareCards(card, opponent, roundChallenge);

    final result = RoundResult(card, opponent, roundChallenge, outcome);
    results.add(result);
    return result;
  }
}
