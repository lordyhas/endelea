import 'dart:io';

import 'package:endelea/data/database.dart';
import 'package:uuid/uuid.dart';

/// Keys of the local-only [SyncMeta] table.
abstract final class SyncMetaKeys {
  static const deviceId = 'deviceId';
  static const lastPushAt = 'lastPushAt';
  static const lastPullCursor = 'lastPullCursor';
  static const provider = 'provider';
  static const accountEmail = 'accountEmail';
  static const lastSyncAt = 'lastSyncAt';
}

/// Reads and writes the local sync bookkeeping. Never synced.
class SyncMetaRepository {
  SyncMetaRepository(this._db);

  final AppDatabase _db;

  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.syncMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) {
    return _db
        .into(_db.syncMeta)
        .insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: key, value: value),
        );
  }

  Future<void> remove(String key) {
    return (_db.delete(_db.syncMeta)..where((t) => t.key.equals(key))).go();
  }

  /// Returns this device's id, generating it on first launch.
  ///
  /// [marker] is a file outside the system backup: when the database comes
  /// from a backup restored on another phone, the marker is missing and the
  /// device gets a new id, so two phones never share one.
  Future<String> ensureDeviceId({File? marker}) async {
    final existing = await read(SyncMetaKeys.deviceId);
    if (existing != null) {
      if (marker == null || await _markerMatches(marker, existing)) {
        return existing;
      }
      // Restored backup: everything must be pushed again under the new id.
      await remove(SyncMetaKeys.lastPushAt);
    }
    final id = const Uuid().v4();
    await write(SyncMetaKeys.deviceId, id);
    await marker?.writeAsString(id);
    return id;
  }

  static Future<bool> _markerMatches(File marker, String id) async {
    try {
      return marker.existsSync() && (await marker.readAsString()) == id;
    } on FileSystemException {
      return false;
    }
  }

  Future<DateTime?> readDate(String key) async {
    final value = await read(key);
    return value == null ? null : DateTime.parse(value);
  }

  Future<void> writeDate(String key, DateTime value) =>
      write(key, value.toUtc().toIso8601String());
}
