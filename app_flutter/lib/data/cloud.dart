import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/saved_team.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

const cloudEnabled = supabaseUrl != '' && supabaseKey != '';

class TeamsRepository {
  final SupabaseClient db;
  TeamsRepository(this.db);

  SupabaseQueryBuilder get _table => db.from('equipos');

  Future<List<SavedTeam>> list() async {
    final rows = await _table.select().order('creado', ascending: false);
    return rows.map(SavedTeam.fromJson).toList();
  }

  Future<void> create(String name, List<String> cards) async {
    await _table.insert({'nombre': name.trim(), 'cartas': cards});
  }

  Future<void> rename(int id, String name) async {
    await _table.update({'nombre': name.trim()}).eq('id', id);
  }

  Future<void> delete(int id) async {
    await _table.delete().eq('id', id);
  }
}
