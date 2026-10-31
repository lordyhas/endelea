import 'package:drift/drift.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/write_stamp.dart';

class BodyRepository {
  BodyRepository(this._db, this._stamp);

  final AppDatabase _db;
  final WriteStamp _stamp;

  /// Measurements, oldest first.
  Stream<List<BodyMeasurement>> watchAll() {
    return (_db.select(_db.bodyMeasurements)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.measuredAt)]))
        .watch();
  }

  Future<String> add({
    required DateTime measuredAt,
    double? bodyWeightKg,
    double? bodyFatPercent,
    String? notes,
  }) async {
    final now = _stamp.now();
    final row = await _db
        .into(_db.bodyMeasurements)
        .insertReturning(
          BodyMeasurementsCompanion.insert(
            measuredAt: normalizeTimestamp(measuredAt),
            bodyWeightKg: Value(bodyWeightKg),
            bodyFatPercent: Value(bodyFatPercent),
            notes: Value(notes),
            createdAt: Value(now),
            updatedAt: Value(now),
            lastModifiedBy: Value(_stamp.deviceId),
          ),
        );
    return row.id;
  }

  Future<void> update(
    String id, {
    required DateTime measuredAt,
    double? bodyWeightKg,
    double? bodyFatPercent,
  }) {
    return (_db.update(
      _db.bodyMeasurements,
    )..where((t) => t.id.equals(id))).write(
      BodyMeasurementsCompanion(
        measuredAt: Value(normalizeTimestamp(measuredAt)),
        bodyWeightKg: Value(bodyWeightKg),
        bodyFatPercent: Value(bodyFatPercent),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> delete(String id) {
    return (_db.update(
      _db.bodyMeasurements,
    )..where((t) => t.id.equals(id))).write(
      BodyMeasurementsCompanion(
        deleted: const Value(true),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }
}
