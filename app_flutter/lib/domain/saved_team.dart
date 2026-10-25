class SavedTeam {
  final int id;
  final String name;
  final List<String> cards;
  final DateTime created;

  const SavedTeam({
    required this.id,
    required this.name,
    required this.cards,
    required this.created,
  });

  factory SavedTeam.fromJson(Map<String, dynamic> row) => SavedTeam(
    id: row['id'] as int,
    name: row['nombre'] as String,
    cards: List<String>.from(row['cartas'] as List),
    created: DateTime.parse(row['creado'] as String),
  );
}
