enum Challenge { ranking, titles, winRate }

extension ChallengeLabel on Challenge {
  String get label => switch (this) {
    Challenge.ranking => 'Ranking',
    Challenge.titles => 'Títulos',
    Challenge.winRate => '% de victorias',
  };

  String get rule => switch (this) {
    Challenge.ranking => 'Gana el número menor',
    Challenge.titles => 'Gana el número mayor',
    Challenge.winRate => 'Gana el porcentaje mayor',
  };

  bool get lowerWins => this == Challenge.ranking;
}

class TennisCard {
  final String id;
  final String name;
  final String country;
  final int ranking;
  final int titles;
  final double winRate;

  const TennisCard({
    required this.id,
    required this.name,
    required this.country,
    required this.ranking,
    required this.titles,
    required this.winRate,
  });

  factory TennisCard.fromJson(Map<String, dynamic> json) {
    final card = TennisCard(
      id: json['id'].toString(),
      name: json['name'] as String,
      country: json['country'] as String,
      ranking: (json['ranking'] as num).toInt(),
      titles: (json['titles'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
    );
    if (!card._isValid) {
      throw const FormatException('Carta con datos inválidos');
    }
    return card;
  }

  bool get _isValid =>
      id.isNotEmpty &&
      name.trim().isNotEmpty &&
      ranking >= 1 &&
      titles >= 0 &&
      winRate.isFinite &&
      winRate >= 0 &&
      winRate <= 100;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'ranking': ranking,
    'titles': titles,
    'winRate': winRate,
  };

  String get firstName {
    final space = name.indexOf(' ');
    return space == -1 ? '' : name.substring(0, space);
  }

  String get lastName {
    final space = name.indexOf(' ');
    return space == -1 ? name : name.substring(space + 1);
  }

  double value(Challenge challenge) => switch (challenge) {
    Challenge.ranking => ranking.toDouble(),
    Challenge.titles => titles.toDouble(),
    Challenge.winRate => winRate,
  };
}
