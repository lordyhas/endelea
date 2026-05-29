import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'key_value_storage.dart';

/// Stores each key as a json file in a folder.
class FileStorage implements KeyValueStorage {
  FileStorage(this.directory);

  final Directory directory;

  /// Storage in an `endelea` folder inside the app documents folder.
  static Future<FileStorage> inDocuments() async {
    final documents = await getApplicationDocumentsDirectory();
    return FileStorage(Directory('${documents.path}/endelea'));
  }

  File _file(String key) => File('${directory.path}/$key.json');

  @override
  Future<String?> read(String key) async {
    final file = _file(key);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  /// Writes to a temporary file first so a crash never leaves half a file.
  @override
  Future<void> write(String key, String value) async {
    await directory.create(recursive: true);
    final file = _file(key);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(value, flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<void> delete(String key) async {
    final file = _file(key);
    if (await file.exists()) await file.delete();
  }
}
