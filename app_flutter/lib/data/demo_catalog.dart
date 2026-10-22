import '../domain/tennis_card.dart';

List<TennisCard> demoCatalog() {
  const rows = [
    // Scheme (nombre, país, ranking, títulos, % victorias)

    ('Jannik Sinner', 'ITA', 1, 19, 82.0),
    ('Carlos Alcaraz', 'ESP', 2, 21, 81.0),
    ('Alexander Zverev', 'GER', 3, 23, 70.0),
    ('Novak Djokovic', 'SRB', 4, 30, 84.0),
    ('Taylor Fritz', 'USA', 5, 9, 66.0),
    ('Jack Draper', 'GBR', 6, 4, 64.0),
    ('Alex de Miñaur', 'AUS', 7, 9, 65.0),
    ('Lorenzo Musetti', 'ITA', 8, 3, 61.0),
    ('Holger Rune', 'DEN', 9, 4, 62.0),
    ('Casper Ruud', 'NOR', 10, 12, 64.0),
    ('Ben Shelton', 'USA', 11, 3, 60.0),
    ('Tommy Paul', 'USA', 12, 4, 61.0),
    ('Stefanos Tsitsipas', 'GRE', 13, 12, 68.0),
    ('Frances Tiafoe', 'USA', 14, 3, 57.0),
    ('Félix Auger-Aliassime', 'CAN', 15, 7, 60.0),
    ('Grigor Dimitrov', 'BUL', 16, 9, 63.0),
    ('Hubert Hurkacz', 'POL', 17, 8, 61.0),
    ('Ugo Humbert', 'FRA', 18, 7, 58.0),
    ('Arthur Fils', 'FRA', 19, 3, 59.0),
    ('Francisco Cerúndolo', 'ARG', 20, 4, 57.0),
    ('Alejandro Davidovich Fokina', 'ESP', 21, 2, 55.0),
    ('Jakub Menšík', 'CZE', 22, 2, 58.0),
    ('João Fonseca', 'BRA', 23, 1, 60.0),
    ('Sebastian Korda', 'USA', 24, 3, 56.0),
  ];
  return [
    for (var i = 0; i < rows.length; i++)
      TennisCard(
        id: 'demo-${i + 1}',
        name: rows[i].$1,
        country: rows[i].$2,
        ranking: rows[i].$3,
        titles: rows[i].$4,
        winRate: rows[i].$5,
      ),
  ];
}
