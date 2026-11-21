import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:endelea/data/repositories/row_store.dart';
import 'package:equatable/equatable.dart';

/// A batch of changes written by one device (PLAN.md §9.2).
class ChangeBatch extends Equatable {
  const ChangeBatch({
    required this.deviceId,
    required this.createdAt,
    required this.tables,
  });

  final String deviceId;
  final DateTime createdAt;
  final Map<String, List<RawRow>> tables;

  bool get isEmpty => tables.values.every((rows) => rows.isEmpty);

  int get rowCount => tables.values.fold(0, (sum, rows) => sum + rows.length);

  @override
  List<Object?> get props => [deviceId, createdAt, tables];
}

/// The cloud files cannot be read by this version of the app.
class UnsupportedSyncFormatException implements Exception {
  const UnsupportedSyncFormatException(this.formatVersion);

  final Object? formatVersion;
}

/// (De)serializes sync files: JSON, gzip-compressed.
class SyncCodec {
  const SyncCodec();

  static const formatVersion = 1;
  static const root = 'endelea';
  static const manifestName = '$root/manifest.json';
  static const changesPrefix = '$root/changes/';

  /// `endelea/changes/<deviceId>/<epochMillis>.json.gz`.
  static String batchName(String deviceId, DateTime createdAt) =>
      '$changesPrefix$deviceId/${createdAt.millisecondsSinceEpoch}.json.gz';

  /// Device id and time of a batch file name, or null for other files.
  static ({String deviceId, int millis})? parseBatchName(String name) {
    if (!name.startsWith(changesPrefix) || !name.endsWith('.json.gz')) {
      return null;
    }
    final parts = name
        .substring(changesPrefix.length, name.length - '.json.gz'.length)
        .split('/');
    if (parts.length != 2) return null;
    final millis = int.tryParse(parts[1]);
    if (millis == null || parts[0].isEmpty) return null;
    return (deviceId: parts[0], millis: millis);
  }

  List<int> encodeBatch(ChangeBatch batch) {
    final json = jsonEncode({
      'formatVersion': formatVersion,
      'deviceId': batch.deviceId,
      'createdAt': batch.createdAt.toUtc().toIso8601String(),
      'tables': batch.tables,
    });
    return const GZipEncoder().encodeBytes(utf8.encode(json));
  }

  ChangeBatch decodeBatch(List<int> bytes) {
    final json = utf8.decode(const GZipDecoder().decodeBytes(bytes));
    final map = jsonDecode(json) as Map<String, Object?>;
    final version = map['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw UnsupportedSyncFormatException(version);
    }
    final tables = (map['tables'] as Map<String, Object?>?) ?? const {};
    return ChangeBatch(
      deviceId: map['deviceId']! as String,
      createdAt: DateTime.parse(map['createdAt']! as String),
      tables: {
        for (final MapEntry(key: table, value: rows) in tables.entries)
          if (rows is List)
            table: [
              for (final row in rows)
                if (row is Map<String, Object?>) row,
            ],
      },
    );
  }

  List<int> encodeManifest({
    required int schemaVersion,
    required DateTime createdAt,
  }) {
    return utf8.encode(
      jsonEncode({
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'createdAt': createdAt.toUtc().toIso8601String(),
      }),
    );
  }

  /// Format version of a manifest.
  int? manifestVersion(List<int> bytes) {
    final map = jsonDecode(utf8.decode(bytes));
    if (map is! Map<String, Object?>) return null;
    final version = map['formatVersion'];
    return version is int ? version : null;
  }
}
