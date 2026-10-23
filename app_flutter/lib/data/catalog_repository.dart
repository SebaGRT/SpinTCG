import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/tennis_card.dart';
import 'demo_catalog.dart';

class CatalogRepository {
  final String baseUrl;
  final http.Client client;

  CatalogRepository(this.baseUrl, {http.Client? client})
    : client = client ?? http.Client();

  bool get isDemo => baseUrl.isEmpty;

  Future<List<TennisCard>> load() async {
    if (isDemo) return demoCatalog();

    final root = Uri.parse(baseUrl);
    final validUrl =
        root.hasScheme &&
        ['http', 'https'].contains(root.scheme) &&
        root.host.isNotEmpty;
    if (!validUrl) {
      throw const FormatException('API_BASE_URL debe ser una URL http o https');
    }

    final response = await client
        .get(root.resolve('/catalog'))
        .timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      throw StateError('Servicio de tenis: HTTP ${response.statusCode}');
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (payload['source'] != 'rapidapi') {
      throw const FormatException(
        'El servicio no identifica datos de RapidAPI',
      );
    }

    final cards = (payload['cards'] as List)
        .map((c) => TennisCard.fromJson(Map<String, dynamic>.from(c)))
        .toList();
    final uniqueIds = cards.map((c) => c.id).toSet().length;
    if (cards.length < 6 || uniqueIds != cards.length) {
      throw const FormatException(
        'Se requieren al menos seis cartas válidas y únicas',
      );
    }
    return cards;
  }

  void dispose() => client.close();
}
