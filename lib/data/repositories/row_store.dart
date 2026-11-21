import 'package:drift/drift.dart';
import 'package:endelea/data/database.dart';

/// A row as stored in SQLite: column name (snake_case) → value.
///
/// Values are JSON-friendly: text (dates are ISO-8601 UTC strings), int
/// (booleans are 0/1), real, or null.
typedef RawRow = Map<String, Object?>;

/// Result of [RowStore.merge].
class MergeResult {
  const MergeResult({this.applied = 0, this.skipped = 0});

  /// Rows inserted or replaced.
  final int applied;

  /// Rows older than the local version.
  final int skipped;

  MergeResult operator +(MergeResult other) => MergeResult(
    applied: applied + other.applied,
    skipped: skipped + other.skipped,
  );
}

/// Reads and writes synced tables row by row, for the JSON export/import
/// (PLAN.md §9.8) and the cloud sync (§9.3).
///
/// Writes keep the incoming `updated_at` and `last_modified_by`: a merged
/// row must not look like a new local change.
class RowStore {
  RowStore(this._db);

  final AppDatabase _db;

  /// Rows of [table] changed after [since] (all rows when null), deleted
  /// ones included.
  Future<List<RawRow>> changedSince(String table, DateTime? since) async {
    _checkTable(table);
    final rows = since == null
        ? await _db.customSelect('SELECT * FROM $table').get()
        : await _db
              .customSelect(
                'SELECT * FROM $table WHERE updated_at > ?',
                variables: [Variable.withString(_iso(since))],
              )
              .get();
    return [for (final row in rows) Map.of(row.data)];
  }

  /// Every non-deleted row of every synced table (export).
  Future<Map<String, List<RawRow>>> readAll() async {
    return {
      for (final table in syncedTableNames)
        table: [
          for (final row
              in await _db
                  .customSelect('SELECT * FROM $table WHERE deleted = 0')
                  .get())
            Map.of(row.data),
        ],
    };
  }

  /// Merges incoming rows, table by table in [syncedTableNames] order,
  /// last write wins per row: the incoming row replaces the local one if it
  /// is newer, or as new with a greater `last_modified_by` (deterministic
  /// tie-break). Deletions follow the same rule.
  Future<MergeResult> merge(Map<String, List<RawRow>> tables) {
    return _db.transaction(() async {
      // Rows may arrive before their parents within a batch.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      var result = const MergeResult();
      for (final table in syncedTableNames) {
        final rows = tables[table];
        if (rows == null || rows.isEmpty) continue;
        result += await _mergeTable(table, rows);
      }
      return result;
    });
  }

  Future<MergeResult> _mergeTable(String table, List<RawRow> rows) async {
    final columns = await _columns(table);
    var applied = 0;
    var skipped = 0;
    for (final incoming in rows) {
      final id = incoming['id'];
      if (id is! String) continue;
      final local = await _db
          .customSelect(
            'SELECT updated_at, last_modified_by FROM $table WHERE id = ?',
            variables: [Variable.withString(id)],
          )
          .getSingleOrNull();
      if (local != null && !_isNewer(incoming, local.data)) {
        skipped++;
        continue;
      }
      // Unknown columns (newer app version) are ignored; missing ones get
      // their default through INSERT OR REPLACE.
      final names = [
        for (final column in columns)
          if (incoming.containsKey(column)) column,
      ];
      await _db.customInsert(
        'INSERT OR REPLACE INTO $table (${names.join(', ')}) '
        'VALUES (${List.filled(names.length, '?').join(', ')})',
        variables: [for (final name in names) _variable(incoming[name])],
        updates: {_tableInfo(table)},
      );
      applied++;
    }
    return MergeResult(applied: applied, skipped: skipped);
  }

  static bool _isNewer(RawRow incoming, Map<String, Object?> local) {
    final a = '${incoming['updated_at'] ?? ''}';
    final b = '${local['updated_at'] ?? ''}';
    final byDate = _compareDates(a, b);
    if (byDate != 0) return byDate > 0;
    final byDevice = '${incoming['last_modified_by'] ?? ''}'.compareTo(
      '${local['last_modified_by'] ?? ''}',
    );
    return byDevice > 0;
  }

  /// Compares two stored dates; parses them in case of different formats.
  static int _compareDates(String a, String b) {
    final da = DateTime.tryParse(a);
    final db = DateTime.tryParse(b);
    if (da == null || db == null) return a.compareTo(b);
    return da.compareTo(db);
  }

  Future<List<String>> _columns(String table) async {
    final info = await _db.customSelect('PRAGMA table_info($table)').get();
    return [for (final row in info) row.read<String>('name')];
  }

  TableInfo<Table, dynamic> _tableInfo(String table) =>
      _db.allTables.firstWhere((t) => t.actualTableName == table);

  static void _checkTable(String table) {
    if (!syncedTableNames.contains(table)) {
      throw ArgumentError.value(table, 'table', 'not a synced table');
    }
  }

  static String _iso(DateTime date) => date.toUtc().toIso8601String();

  static Variable<Object> _variable(Object? value) => switch (value) {
    null => const Variable(null),
    final String v => Variable.withString(v),
    final int v => Variable.withInt(v),
    final double v => Variable.withReal(v),
    final bool v => Variable.withInt(v ? 1 : 0),
    _ => Variable.withString('$value'),
  };
}
