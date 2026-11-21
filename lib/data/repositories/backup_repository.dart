import 'dart:convert';

import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/row_store.dart';

/// The file is not an Endelea export, or comes from a newer version.
class InvalidExportException implements Exception {
  const InvalidExportException(this.reason);

  final String reason;

  @override
  String toString() => 'InvalidExportException: $reason';
}

/// Manual JSON export and import (PLAN.md §9.8), the safety net next to the
/// cloud sync.
class BackupRepository {
  BackupRepository(this._db, this._rows);

  final AppDatabase _db;
  final RowStore _rows;

  static const format = 'endelea-export';
  static const formatVersion = 1;

  /// Every non-deleted row of every synced table, as JSON.
  Future<String> exportJson(DateTime now) async {
    return const JsonEncoder.withIndent('  ').convert({
      'format': format,
      'formatVersion': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': now.toUtc().toIso8601String(),
      'tables': await _rows.readAll(),
    });
  }

  /// `endelea-export-2026-11-21.json`.
  static String fileName(DateTime now) {
    final local = now.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'endelea-export-${local.year}-${two(local.month)}-${two(local.day)}.json';
  }

  /// Merges an export into the database with the sync rule (last write
  /// wins per row).
  Future<MergeResult> importJson(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const InvalidExportException('not JSON');
    }
    if (decoded is! Map<String, Object?> || decoded['format'] != format) {
      throw const InvalidExportException('not an Endelea export');
    }
    final version = decoded['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw const InvalidExportException('unsupported version');
    }
    final tables = decoded['tables'];
    if (tables is! Map<String, Object?>) {
      throw const InvalidExportException('no tables');
    }
    return _rows.merge({
      for (final MapEntry(key: table, value: rows) in tables.entries)
        if (syncedTableNames.contains(table) && rows is List)
          table: [
            for (final row in rows)
              if (row is Map<String, Object?>) row,
          ],
    });
  }
}
