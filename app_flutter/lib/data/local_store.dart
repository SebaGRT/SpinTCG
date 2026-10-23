import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class LocalStore {
  Future<Map<String, dynamic>?> read();
  Future<void> write(Map<String, dynamic> data);
}

class FileLocalStore implements LocalStore {
  final String namespace;

  FileLocalStore(this.namespace);

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return File('${dir.path}/spintcg_$namespace.json');
  }

  @override
  Future<Map<String, dynamic>?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    return Map<String, dynamic>.from(jsonDecode(await file.readAsString()));
  }

  @override
  Future<void> write(Map<String, dynamic> data) async {
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data), flush: true);
    await tmp.rename(file.path);
  }
}

class MemoryLocalStore implements LocalStore {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> read() async =>
      data == null ? null : jsonDecode(jsonEncode(data));

  @override
  Future<void> write(Map<String, dynamic> value) async {
    data = jsonDecode(jsonEncode(value));
  }
}
