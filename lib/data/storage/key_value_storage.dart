/// Saves text documents by key, such as one json file per kind of data.
abstract interface class KeyValueStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Storage kept in memory, used by tests and as a fallback.
class MemoryStorage implements KeyValueStorage {
  MemoryStorage([Map<String, String>? values]) : values = values ?? {};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
